class Admin::TenantsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_staff!
  before_action :set_tenant, only: [:edit, :update, :destroy]

  def index
    @q = Tenant.ransack(params[:q])
    @tenants = @q.result(distinct: true).order(:name)
  end

  def new
    @tenant = Tenant.new
  end

  def create
    @tenant = Tenant.new(tenant_params)
    if @tenant.save
      redirect_to admin_tenants_path, notice: "Department '#{@tenant.name}' created successfully."
    else
      render :new
    end
  end

  def edit
    # @tenant set by before_action
  end

  def update
    if @tenant.update(tenant_params)
      redirect_to admin_tenants_path, notice: "Department updated successfully."
    else
      render :edit
    end
  end

  def destroy
    if @tenant.name == "Admin"
      redirect_to admin_tenants_path, alert: "The Admin department cannot be deleted."
    elsif @tenant.users.exists? || @tenant.venues.exists? || @tenant.equipment.exists?
      redirect_to admin_tenants_path, alert: "Cannot delete department with associated resources."
    else
      @tenant.destroy
      redirect_to admin_tenants_path, notice: "Department deleted."
    end
  end

  private

  def set_tenant
    @tenant = Tenant.find(params[:id])
  end

  def tenant_params
    params.require(:tenant).permit(:name, :slug)
  end

  def authorize_staff!
    redirect_to root_path, alert: "Access denied." unless current_user.staff?
  end
end