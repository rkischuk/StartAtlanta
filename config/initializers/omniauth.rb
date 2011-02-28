Rails.application.config.middleware.use OmniAuth::Builder do
  #provider :twitter, 'CONSUMER_KEY', 'CONSUMER_SECRET'
  provider :facebook, AppConfig.facebook_app_id, AppConfig.facebook_client_secret
  #provider :linked_in, 'CONSUMER_KEY', 'CONSUMER_SECRET'
end