class VenuesController < ApplicationController
  def index
    @venues = Venue.all
  end

  def show
  end

  def new
  end

  def edit
  end
end
