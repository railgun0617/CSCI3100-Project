class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end

class ApplicationController < ActionController::Base
  # Dummy methods to make views work without authentication
  # TODO: Remove these once Devise is set up

  def current_user
    @current_user ||= User.first || User.create(email: "test@example.com", password: "password")
  end
  helper_method :current_user

  def user_signed_in?
    true
  end
  helper_method :user_signed_in?
end