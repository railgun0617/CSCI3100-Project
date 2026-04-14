#!/bin/bash
set -e

PROJECT_ID=$(gcloud config get-value project)
BUCKET_NAME="${PROJECT_ID}-sqlite-storage"
REGION="us-central1"
SERVICE_NAME="csci3100-sqlite"
SECRET_KEY_BASE=$(openssl rand -hex 64)

echo "=== Creating Cloud Storage bucket ==="
gsutil ls gs://$BUCKET_NAME || gsutil mb -l $REGION gs://$BUCKET_NAME

echo "=== Building and pushing Docker image ==="
gcloud builds submit --tag gcr.io/$PROJECT_ID/$SERVICE_NAME

echo "=== Deploying to Cloud Run (first pass) ==="
gcloud run deploy $SERVICE_NAME \
  --image gcr.io/$PROJECT_ID/$SERVICE_NAME \
  --platform managed \
  --region $REGION \
  --allow-unauthenticated \
  --memory 1Gi \
  --concurrency 10 \
  --min-instances 1 \
  --max-instances 1 \
  --add-volume name=sqlite-data,type=cloud-storage,bucket=$BUCKET_NAME \
  --add-volume-mount volume=sqlite-data,mount-path=/app/storage \
  --set-env-vars "RAILS_ENV=production,SECRET_KEY_BASE=$SECRET_KEY_BASE,SEND_EMAILS=true,SOLID_QUEUE_IN_PUMA=true"

echo "=== Retrieving the service URL ==="
SERVICE_URL=$(gcloud run services describe $SERVICE_NAME --region $REGION --format 'value(status.url)')
APP_HOST=$(echo $SERVICE_URL | sed 's|https://||')
echo "Service URL: $SERVICE_URL"
echo "APP_HOST: $APP_HOST"

echo "=== Updating service with APP_HOST ==="
gcloud run services update $SERVICE_NAME \
  --region $REGION \
  --set-env-vars "RAILS_ENV=production,SECRET_KEY_BASE=$SECRET_KEY_BASE,SEND_EMAILS=true,SOLID_QUEUE_IN_PUMA=true,APP_HOST=$APP_HOST,APP_PROTOCOL=https"

echo "=== Granting IAM permissions to the Cloud Run service account ==="
PROJECT_NUMBER=$(gcloud projects describe $PROJECT_ID --format 'value(projectNumber)')
SA_EMAIL="$PROJECT_NUMBER-compute@developer.gserviceaccount.com"
gsutil iam ch "serviceAccount:$SA_EMAIL:objectAdmin" gs://$BUCKET_NAME

echo "=== Running database migrations ==="
gcloud run jobs create migrate-db --quiet --image gcr.io/$PROJECT_ID/$SERVICE_NAME \
  --command "bundle","exec","rails","db:migrate" \
  --region $REGION \
  --add-volume name=sqlite-data,type=cloud-storage,bucket=$BUCKET_NAME \
  --add-volume-mount volume=sqlite-data,mount-path=/app/storage \
  --set-env-vars "RAILS_ENV=production,SECRET_KEY_BASE=$SECRET_KEY_BASE" || true

gcloud run jobs execute migrate-db --region $REGION --wait

echo "=== Deployment complete ==="
echo "Your app is available at: $SERVICE_URL"