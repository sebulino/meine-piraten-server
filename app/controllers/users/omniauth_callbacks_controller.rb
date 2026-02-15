class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  skip_before_action :verify_authenticity_token, only: :openid_connect

  def openid_connect
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: "PiratenSSO") if is_navigational_format?
    else
      redirect_to root_path, alert: "Anmeldung fehlgeschlagen."
    end
  end

  def failure
    redirect_to root_path, alert: "Anmeldung fehlgeschlagen: #{failure_message}"
  end
end
