class DevicesController < ApplicationController
  def index
    @devices = Device.all
  end

  def show
    @device = Device.find_by(model: params[:device_model])
  end
end
