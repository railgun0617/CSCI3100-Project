class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_staff!

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.role = 'staff'  # force staff role
    if @user.save
      redirect_to staff_dashboard_path, notice: "Staff account created for #{@user.email}."
    else
      render :new
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation, :tenant_id)
  end

  def authorize_staff!
    redirect_to root_path, alert: "Access denied." unless current_user.staff?
  end
end