Rails.application.routes.draw do
  get '/', to: 'devices#index'
  get '/devices/:device_model', to: 'devices#show', constraints: { device_model: /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/ }
  get '/devices/:device_model', to: redirect(status: 303) { |params, request| "/devices/#{params[:device_model].downcase}" }, constraints: { device_model: /(?!.*[A-Z])[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}/ }
end
