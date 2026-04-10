class ResourcesController < ApplicationController
  def index
    if params[:q].present? && params[:q][:name_or_description_or_location_cont].present?
      search_term = params[:q][:name_or_description_or_location_cont]

      venue_results     = Venue.ransack(name_or_description_cont: search_term).result
      equipment_results = Equipment.ransack(name_or_description_or_location_cont: search_term).result

      @resources = (venue_results + equipment_results).uniq
    else
      @resources = Venue.all + Equipment.all
    end

    @resources = @resources.sort_by(&:name)
  end
end