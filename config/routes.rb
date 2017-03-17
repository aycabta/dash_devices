Rails.application.routes.draw do
  root 'devices#index'
  get '/devices/:device_model', to: 'devices#show'
  post '/devices/create', to: 'devices#create'
  get '/auth/:provider/callback', to: 'sessions#create'
  post '/logout', to: 'sessions#destroy'
end
