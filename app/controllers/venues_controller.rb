class VenuesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_staff!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_venue, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.staff? && current_user.tenant&.name == "Admin"
      @q = Venue.ransack(params[:q])
      @venues = @q.result(distinct: true).order(:name)
    elsif current_user.staff?
      @q = current_user.tenant.venues.ransack(params[:q])
      @venues = @q.result(distinct: true).order(:name)
    else
      @q = Venue.ransack(params[:q])
      @venues = @q.result(distinct: true).order(:name)
    end
  end

  def show
    # @venue set by before_action
  end

  def new
    @venue = Venue.new
    @venue.tenant = current_user.tenant if current_user.staff?
  end

  def edit
    # @venue set by before_action
  end

  def create
    @venue = Venue.new(venue_params)
    if current_user.staff? && current_user.tenant&.name == "Admin"
      # Admin can assign any tenant; if not provided, use their own
      @venue.tenant_id = venue_params[:tenant_id] if venue_params[:tenant_id].present?
    elsif current_user.staff?
      @venue.tenant = current_user.tenant
    end
    if @venue.save
      redirect_to @venue, notice: 'Venue was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @venue.update(venue_params)
      redirect_to @venue, notice: 'Venue was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @venue.destroy
    redirect_to venues_path, notice: 'Venue was deleted.'
  end

  private

  def set_venue
    if current_user.staff? && current_user.tenant&.name == "Admin"
      @venue = Venue.find(params[:id])
    elsif current_user.staff?
      @venue = current_user.tenant.venues.find(params[:id])
    else
      @venue = Venue.find(params[:id])
    end
  end

  def venue_params
    if current_user.staff? && current_user.tenant&.name == "Admin"
      params.require(:venue).permit(:name, :description, :capacity, :open_time, :close_time, :latitude, :longitude, :tenant_id)
    else
      params.require(:venue).permit(:name, :description, :capacity, :open_time, :close_time, :latitude, :longitude)
    end
  end

  def authorize_staff!
    redirect_to root_path, alert: 'Access denied.' unless current_user.staff?
  end
end