class VenuesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_staff!, only: [:new, :create, :edit, :update, :destroy]

  def index
    @venues = Venue.all
  end

  def show
    @venue = Venue.find(params[:id])
  end

  def new
    @venue = Venue.new
  end

  def edit
    @venue = Venue.find(params[:id])   # This line is critical
  end

  def create
    @venue = Venue.new(venue_params)
    if @venue.save
      redirect_to @venue, notice: 'Venue was successfully created.'
    else
      render :new
    end
  end

  def update
    @venue = Venue.find(params[:id])
    if @venue.update(venue_params)
      redirect_to @venue, notice: 'Venue was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @venue = Venue.find(params[:id])
    @venue.destroy
    redirect_to venues_path, notice: 'Venue was deleted.'
  end

  private

  def venue_params
    params.require(:venue).permit(:name, :description, :capacity, :latitude, :longitude)
  end

  def authorize_staff!
    redirect_to root_path, alert: 'Access denied.' unless current_user.staff?
  end
end
