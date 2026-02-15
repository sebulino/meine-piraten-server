OmniAuth.config.logger = Rails.logger
OmniAuth.config.on_failure = proc do |env|
  Users::OmniauthCallbacksController.action(:failure).call(env)
end
