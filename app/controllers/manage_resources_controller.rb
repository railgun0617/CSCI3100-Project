class ManageResourcesController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_staff!

  def index
    @venues = Venue.all
    @equipment = Equipment.all
  end

  private

  def authorize_staff!
    redirect_to root_path, alert: "Access denied." unless current_user.staff?
  end
end