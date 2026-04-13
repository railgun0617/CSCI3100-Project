class EquipmentController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_staff!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_equipment, only: [:show, :edit, :update, :destroy]

  def index
    if current_user.staff? && current_user.tenant&.name == "Admin"
      # Admin sees all equipment (no tenant filter)
      @q = Equipment.ransack(params[:q])
      @equipment = @q.result(distinct: true).order(:name)
    elsif current_user.staff?
      @q = current_user.tenant.equipment.ransack(params[:q])
      @equipment = @q.result(distinct: true).order(:name)
    else
      @q = Equipment.ransack(params[:q])
      @equipment = @q.result(distinct: true).order(:name)
    end
  end

  def show
    # @equipment set by before_action
  end

  def new
    @equipment = Equipment.new(flash[:equipment_params] || {})
    # For non‑admin staff, pre‑assign their tenant; admin will choose via form
    if current_user.staff? && current_user.tenant&.name != "Admin"
      @equipment.tenant = current_user.tenant
    end
  end

  def edit
    # @equipment set by before_action
  end

  def create
    @equipment = Equipment.new(equipment_params)

    # Non‑admin staff: force tenant to their own tenant (ignore any passed tenant_id)
    if current_user.staff? && current_user.tenant&.name != "Admin"
      @equipment.tenant = current_user.tenant
    end

    if @equipment.save
      redirect_to @equipment, notice: 'Equipment was successfully created.'
    else
      redirect_to new_equipment_path, 
                alert: @equipment.errors.full_messages.to_sentence,
                flash: { equipment_params: equipment_params }
    end
  end

  def update
    if @equipment.update(equipment_params)
      redirect_to @equipment, notice: 'Equipment was successfully updated.'
    else
      redirect_to edit_equipment_path(@equipment),
                alert: @equipment.errors.full_messages.to_sentence
    end
  end

  def destroy
    @equipment.destroy
    redirect_to equipment_index_path, notice: 'Equipment was successfully deleted.'
  end

  private

  def set_equipment
    @equipment = if current_user.staff? && current_user.tenant&.name == "Admin"
                   # Admin can access any equipment
                   Equipment.find(params[:id])
                 elsif current_user.staff?
                   # Normal staff can only access equipment from their tenant
                   current_user.tenant.equipment.find(params[:id])
                 else
                   Equipment.find(params[:id])
                 end
  end

  def equipment_params
    if current_user.staff? && current_user.tenant&.name == "Admin"
      # Admin can set tenant_id
      params.require(:equipment).permit(:name, :description, :location, :quantity, :latitude, :longitude, :tenant_id)
    else
      # Non‑admin staff and students cannot set tenant_id
      params.require(:equipment).permit(:name, :description, :location, :quantity, :latitude, :longitude)
    end
  end

  def authorize_staff!
    redirect_to root_path, alert: 'Access denied.' unless current_user.staff?
  end
end