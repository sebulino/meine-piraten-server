class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  before_action :authenticate_request!

  private

  def authenticate_request!
    if Rails.env.development?
      sign_in_dev_user unless user_signed_in?
      return
    end

    if request.format.json?
      authenticate_api_request!
    else
      authenticate_user!
    end
  end

  def sign_in_dev_user
    dev_user = User.find_or_create_by(provider: "openid_connect", uid: "dev-local") do |user|
      user.email = "dev@localhost"
      user.name = "Dev User"
      user.preferred_username = "dev"
    end
    sign_in(dev_user)
  end

  def authenticate_api_request!
    auth_header = request.headers["Authorization"]
    Rails.logger.info "API auth: Authorization header #{auth_header.present? ? 'present' : 'MISSING'}"
    Rails.logger.info "API auth: Request headers: #{request.headers.env.select { |k, _| k.start_with?('HTTP_') }.to_h}" if auth_header.blank?

    token = auth_header&.delete_prefix("Bearer ")
    if token.blank?
      render json: { error: "Authorization header required" }, status: :unauthorized
      return
    end

    payload = KeycloakTokenVerifier.verify(token)
    @current_api_user = User.find_or_create_by(provider: "openid_connect", uid: payload["sub"]) do |user|
      user.email = payload["email"]
      user.name = payload["name"]
      user.preferred_username = payload["preferred_username"]
    end
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::InvalidIssuerError => e
    render json: { error: "Invalid token: #{e.message}" }, status: :unauthorized
  end
end
