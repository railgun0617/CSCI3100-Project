class BookingsController < ApplicationController
  def index
    @bookings = []  # placeholder – later you'll use current_user.bookings
  end

  def new
  end
end
