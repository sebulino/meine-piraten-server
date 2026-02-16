OmniAuth.config.logger = Rails.logger
OmniAuth.config.allowed_request_methods = [ :post ]
OmniAuth.config.on_failure = proc do |env|
  Rails.logger.error "OmniAuth failure: #{env['omniauth.error']&.message} | type: #{env['omniauth.error.type']} | strategy: #{env['omniauth.error.strategy']&.name}"
  Users::OmniauthCallbacksController.action(:failure).call(env)
end
