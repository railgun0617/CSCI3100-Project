# app/controllers/manage_resources_controller.rb
class ManageResourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_staff!

  def index
    if current_user.staff? && current_user.tenant&.name == "Admin"
      base_venues = Venue.all
      base_equipment = Equipment.all
    else
      base_venues = current_user.tenant&.venues || Venue.none
      base_equipment = current_user.tenant&.equipment || Equipment.none
    end

    if params[:search].present?
      search_term = "%#{params[:search]}%"
      @venues = base_venues.where("name LIKE ? OR description LIKE ?", search_term, search_term)
      @equipment = base_equipment.where("name LIKE ? OR description LIKE ? OR location LIKE ?", search_term, search_term, search_term)
    else
      @venues = base_venues
      @equipment = base_equipment
    end

    @venues = @venues.order(:name)
    @equipment = @equipment.order(:name)
  end

  private

  def authorize_staff!
    redirect_to root_path, alert: "Access denied." unless current_user.staff?
  end
end