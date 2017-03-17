Rails.application.routes.draw do
  root 'devices#index'
  get '/devices/:device_model', to: 'devices#show'
  get '/users/:id', to: 'users#show', as: :users_show
  post '/devices/create', to: 'devices#create'
  get '/auth/:provider/callback', to: 'sessions#create'
  post '/logout', to: 'sessions#destroy'
end
