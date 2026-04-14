class StaffChannel < ApplicationCable::Channel
  def subscribed
    if current_user&.staff?
      stream_from "staff_channel"
    else
      reject
    end
  end

  def unsubscribed
  end
end