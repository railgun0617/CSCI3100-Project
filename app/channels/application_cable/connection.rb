module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user  # identify by current user

    def connect
      self.current_user = find_verified_user  # verify the user
    end

    private

    def find_verified_user
      # Get current user id by Devise
      if current_user = env['warden']&.user
        current_user
      else
        reject_unauthorized_connection  # not allow to connect without login
      end
    end
  end
end