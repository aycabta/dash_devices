class DevicesController < ApplicationController
  def index
    @devices = Device.all
    @new_device = Device.new
  end

  def show
    @device = Device.find_by(model: params[:device_model])
  end

  def create
    @device = Device.find_or_create_by(name: params[:device][:name], model: params[:device][:model], user: current_user)
    redirect_to(action: 'show', device_model: @device.model)
  end
end
