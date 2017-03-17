Rails.application.config.middleware.use OmniAuth::Builder do
  provider :amazon, Rails.application.secrets.amazon_client_id, Rails.application.secrets.amazon_client_secret, scope: 'profile'
end
