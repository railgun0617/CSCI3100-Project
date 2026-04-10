class ManageResourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_staff!

  def index
    if current_user.staff? && current_user.tenant&.name == "Admin"
      @venues = Venue.all
      @equipment = Equipment.all
    else
      @venues = current_user.tenant&.venues || Venue.none
      @equipment = current_user.tenant&.equipment || Equipment.none
    end
  end

  private

  def authorize_staff!
    redirect_to root_path, alert: "Access denied." unless current_user.staff?
  end
end