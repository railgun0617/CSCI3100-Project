class EquipmentController < ApplicationController
  def index
    @equipment = Equipment.all
  end

  def show
    @equipment = Equipment.find(params[:id])
  end

  def new
    @equipment = Equipment.new
  end

  def create
    @equipment = Equipment.new(equipment_params)
    if @equipment.save
      redirect_to @equipment, notice: 'Equipment was successfully created.'
    else
      render :new
    end
  end

  # edit, update, destroy etc. can be added later
  def edit
    @equipment = Equipment.find(params[:id])
  end

  def update
    @equipment = Equipment.find(params[:id])
    if @equipment.update(equipment_params)
      redirect_to @equipment, notice: 'Equipment was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @equipment = Equipment.find(params[:id])
    @equipment.destroy
    redirect_to equipment_index_path, notice: 'Equipment was successfully deleted.'
  end

  private

  def equipment_params
    params.require(:equipment).permit(:name, :description, :location, :quantity, :latitude, :longitude)
  end
end