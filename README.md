# CUHK Venue & Equipment Booking SaaS

## Project Overview

This is a multi-tenant SaaS application for booking venues and equipment across CUHK colleges and departments. The frontend (views, styling, Stimulus controllers) is nearly complete. The backend currently has basic models and controllers but needs full business logic, authentication, and advanced features.

## Current Status (as of March 2025)

- **Frontend**: All core pages (home, venues, equipment, bookings, staff dashboard) are implemented with Tailwind CSS and Stimulus.  
- **Backend Stubs**: Models (`User`, `Venue`, `Equipment`, `Booking`) and basic CRUD controllers exist.  
- **Missing**: Authentication (Devise), conflict detection, approval workflow, advanced features (Google Maps, ActionCable, SendGrid, fuzzy search), testing, deployment.

## What’s Implemented

### Models (with migrations)
- **User**: `email`, `password`, `role` (string) – temporary; will be replaced by Devise.  
- **Venue**: `name`, `description`, `capacity`, `latitude`, `longitude`, `tenant_id`.  
- **Equipment**: `name`, `description`, `location`, `quantity`, `latitude`, `longitude`, `tenant_id`.  
- **Booking**: `user_id`, `venue_id` (optional), `equipment_id` (optional), `start_time`, `end_time`, `status`, `notes`, `tenant_id`.

### Controllers
- `HomeController` – index  
- `VenuesController` – index, show, new, create, edit, update  
- `EquipmentController` – index, show, new, create, edit, update  
- `BookingsController` – index, new, create  
- `StaffController` – dashboard (placeholder)

### Routes
- `root 'home#index'`  
- `resources :venues`  
- `resources :equipment`  
- `resources :bookings, only: [:index, :new, :create]` plus `approve`/`reject` member routes  
- `get 'staff/dashboard', to: 'staff#dashboard'`

### Views (Complete)
- Layout (`application.html.erb`) with navigation  
- Homepage (links to venues & equipment)  
- Venues: index, show, new, edit  
- Equipment: index, show, new, edit  
- Bookings: new (form), index (my bookings)  
- Staff: dashboard (pending approvals)

### Stimulus Controllers
- `search_controller.js` – debounced search with auto‑complete (expects JSON endpoint `/venues/search.json` and `/equipment/search.json`).  
- `map_controller.js` – placeholder for Google Maps (currently displays lat/lng as text).

### Styling
- Tailwind CSS installed (`tailwindcss-rails` gem).  

## What Backend Needs to Do

### 1. Authentication (Devise)
- Install Devise and configure User model.  
- Replace dummy login links in layout with Devise helpers.  
- Implement role-based authorization (students vs staff) – e.g., Pundit.

### 2. Associations & Validations
- Add proper associations in models (e.g., `User has_many :bookings`, `Booking belongs_to :user`, `Booking belongs_to :venue`/`:equipment`).  
- Ensure validations (e.g., booking times, capacity, quantity, conflict detection).

### 3. Conflict Detection
- Prevent double-booking of the same venue/equipment for overlapping time slots.  
- Provide user-friendly error messages in the booking form.

### 4. Approval Workflow
- Implement `approve` and `reject` actions in `BookingsController`.  
- Update booking status accordingly.  
- Notify users (email) when status changes.

### 5. Advanced Features

#### a) Google Maps
- Add Google Maps API key to environment variables.  
- Modify `map_controller.js` to display actual maps with markers (using venue/equipment latitude/longitude).

#### b) Real‑time Updates (ActionCable)
- Create `BookingsChannel`.  
- Broadcast when a booking is created or approved/rejected.  
- Staff dashboard and My Bookings page should update live (frontend already listens for data).

#### c) Email Notifications (SendGrid)
- Set up Action Mailer with SendGrid (SMTP or API).  
- Send confirmation emails after booking creation.  
- Send approval/rejection emails.  
- Schedule daily reminders for upcoming bookings (use Sidekiq or a cron job).

#### d) Fuzzy Search
- Add `pg_search` (or similar) to `Venue` and `Equipment` models.  
- Implement `/venues/search.json` and `/equipment/search.json` endpoints returning JSON with `id` and `name`.  
- The frontend search controller will use these to show auto‑complete suggestions.

### 6. Testing
- Write **RSpec** unit tests for models, services, and controllers.  
- Write **Cucumber** acceptance tests for key user stories (student books venue, staff approves, etc.).  
- Ensure test coverage >80% (SimpleCov).

### 7. Deployment
- Deploy to a public cloud (Render, Koyeb, etc.).  
- Set up environment variables for API keys, database URL, etc.  
- Ensure GitHub Actions runs tests automatically on push.

### 8. Documentation
- Update this README with setup instructions (for running locally).  
- Add a **feature ownership table** (who implemented what) in the README.  
- Include a screenshot of the SimpleCov coverage report.

## Running Locally

1. Clone the repository:
   ```bash
   git clone <repo-url>
   cd CSCI3100-Project
   ```

2. Install dependencies:
   ```bash
   bundle install
   ```

3. Set up the database:
   ```bash
   rails db:create db:migrate db:seed
   ```

4. Start the server (with Tailwind watcher):
   ```bash
   bin/dev
   ```
   If haven't installed Tailwind or the bin/dev script is missing, run:
   ```bash
   rails tailwindcss:install
   ```
   This creates the bin/dev file. Then you can start the server with:
   ```bash
   bin/dev
   ```
   Alternative:\
   Start the Tailwind watcher in one terminal:
   ```bash
   rails tailwindcss:watch
   ```
   Keep this terminal open – it will recompile CSS automatically when you change views.\
   Start the Rails server in another terminal:
   ```bash
   rails server
   ```

6. Visit `http://localhost:3000`.

## File Structure Overview

```
app/
├── controllers/          # Home, venues, equipment, bookings, staff
├── models/               # User, Venue, Equipment, Booking
├── views/                # All HTML/ERB templates
├── javascript/controllers/  # Stimulus (map, search)
├── assets/   # Tailwind source
config/routes.rb
Gemfile
```

## Next Steps for Backend Team

- Set up Devise and replace dummy auth.  
- Add associations, validations, conflict detection, approval actions.  
- Implement advanced features (maps, real‑time, emails, fuzzy search).  
- Write tests and deploy.

## Communication

If any frontend expectations (e.g., JSON format for search, data attributes in views) need adjustment, please coordinate with the frontend team. We can iterate quickly.
