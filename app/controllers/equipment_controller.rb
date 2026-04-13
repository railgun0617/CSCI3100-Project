class EquipmentController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :destroy]
  before_action :authorize_staff!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_equipment, only: [:show, :edit, :update, :destroy]

  def index
    if user_signed_in? && current_user.staff? && current_user.tenant&.name == "Admin"
      base_equipment = Equipment.all
    elsif user_signed_in? && current_user.staff?
      base_equipment = current_user.tenant.equipment
    else
      base_equipment = Equipment.all
    end

    if params[:q].present? && params[:q][:name_or_description_or_location_cont].present?
      search_term = "%#{params[:q][:name_or_description_or_location_cont]}%"
      @equipment = base_equipment
        .joins("LEFT JOIN tenants ON equipment.tenant_id = tenants.id")
        .where("equipment.name LIKE ? OR equipment.description LIKE ? OR equipment.location LIKE ? OR tenants.name LIKE ?",
               search_term, search_term, search_term, search_term)
        .distinct
        .order(:name)
      @q = base_equipment.ransack(params[:q])
    else
      @q = base_equipment.ransack(params[:q])
      @equipment = @q.result(distinct: true).order(:name)
    end
  end

  def show
    # @equipment set by before_action
  end

  def new
    @equipment = Equipment.new(flash[:equipment_params] || {})
    if user_signed_in? && current_user.staff? && current_user.tenant&.name != "Admin"
      @equipment.tenant = current_user.tenant
    end
  end

  def edit
    # @equipment set by before_action
  end

  def create
    @equipment = Equipment.new(equipment_params)

    if user_signed_in? && current_user.staff? && current_user.tenant&.name != "Admin"
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
    if user_signed_in? && current_user.staff? && current_user.tenant&.name == "Admin"
      @equipment = Equipment.find(params[:id])
    elsif user_signed_in? && current_user.staff?
      @equipment = current_user.tenant.equipment.find(params[:id])
    else
      @equipment = Equipment.find(params[:id])
    end
  end

  def equipment_params
    if user_signed_in? && current_user.staff? && current_user.tenant&.name == "Admin"
      params.require(:equipment).permit(:name, :description, :location, :quantity, :latitude, :longitude, :tenant_id)
    else
      params.require(:equipment).permit(:name, :description, :location, :quantity, :latitude, :longitude)
    end
  end

  def authorize_staff!
    redirect_to root_path, alert: 'Access denied.' unless user_signed_in? && current_user.staff?
  end
end