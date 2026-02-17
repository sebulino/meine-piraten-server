class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  protect_from_forgery with: :exception, unless: -> { request.format.json? }

  before_action :authenticate_request!

  helper_method :admin?, :superadmin?

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
      user.admin = true
      user.superadmin = true
    end
    sign_in(dev_user)
  end

  def authenticate_api_request!
    token = request.headers["Authorization"]&.delete_prefix("Bearer ")
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

  def current_user_or_api_user
    current_user || @current_api_user
  end

  def admin?
    current_user_or_api_user&.admin?
  end

  def superadmin?
    current_user_or_api_user&.superadmin?
  end

  def require_superadmin!
    return if superadmin?

    respond_to do |format|
      format.html { redirect_to root_path, alert: "Zugriff verweigert." }
      format.json { render json: { error: "Forbidden" }, status: :forbidden }
    end
  end

  def require_admin!
    return if admin?

    respond_to do |format|
      format.html { redirect_to root_path, alert: "Zugriff verweigert." }
      format.json { render json: { error: "Forbidden" }, status: :forbidden }
    end
  end
end
