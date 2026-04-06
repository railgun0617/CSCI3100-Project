class ResourcesController < ApplicationController
  def index
    @departments = []#Tenant.all
    @resources = (Venue.all + Equipment.all).sort_by(&:created_at)
  end
end