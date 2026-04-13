class VenuesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :authorize_staff!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_venue, only: [:show, :edit, :update, :destroy]

  def index
    # Determine base collection based on user role (if logged in)
    if user_signed_in? && current_user.staff? && current_user.tenant&.name == "Admin"
      base_venues = Venue.all
    elsif user_signed_in? && current_user.staff?
      base_venues = current_user.tenant.venues
    else
      base_venues = Venue.all  # guests and students see all
    end

    if params[:q].present? && params[:q][:name_or_description_cont].present?
      search_term = "%#{params[:q][:name_or_description_cont]}%"
      @venues = base_venues
        .joins("LEFT JOIN tenants ON venues.tenant_id = tenants.id")
        .where("venues.name LIKE ? OR venues.description LIKE ? OR tenants.name LIKE ?",
               search_term, search_term, search_term)
        .distinct
        .order(:name)
      @q = base_venues.ransack(params[:q])
    else
      @q = base_venues.ransack(params[:q])
      @venues = @q.result(distinct: true).order(:name)
    end
  end

  def show
    # @venue set by before_action
  end

  def new
    @venue = Venue.new(flash[:venue_params] || {})
    @venue.tenant = current_user.tenant if current_user.staff?
  end

  def edit
    # @venue set by before_action
  end

  def create
    @venue = Venue.new(venue_params)
    if current_user.staff? && current_user.tenant&.name == "Admin"
      @venue.tenant_id = venue_params[:tenant_id] if venue_params[:tenant_id].present?
    elsif current_user.staff?
      @venue.tenant = current_user.tenant
    end
    if @venue.save
      redirect_to @venue, notice: 'Venue was successfully created.'
    else
      redirect_to new_venue_path,
                  alert: @venue.errors.full_messages.to_sentence,
                  flash: { venue_params: venue_params }
    end
  end

  def update
    if @venue.update(venue_params)
      redirect_to @venue, notice: 'Venue was successfully updated.'
    else
      redirect_to edit_venue_path(@venue),
                  alert: @venue.errors.full_messages.to_sentence
    end
  end

  def destroy
    @venue.destroy
    redirect_to venues_path, notice: 'Venue was successfully deleted.'
  end

  private

  def set_venue
    if user_signed_in? && current_user.staff? && current_user.tenant&.name == "Admin"
      @venue = Venue.find(params[:id])
    elsif user_signed_in? && current_user.staff?
      @venue = current_user.tenant.venues.find(params[:id])
    else
      @venue = Venue.find(params[:id])
    end
  end

  def venue_params
    if user_signed_in? && current_user.staff? && current_user.tenant&.name == "Admin"
      params.require(:venue).permit(:name, :description, :capacity, :open_time, :close_time, :latitude, :longitude, :tenant_id)
    else
      params.require(:venue).permit(:name, :description, :capacity, :open_time, :close_time, :latitude, :longitude)
    end
  end

  def authorize_staff!
    redirect_to root_path, alert: 'Access denied.' unless user_signed_in? && current_user.staff?
  end
end