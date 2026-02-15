class Users::SessionsController < Devise::SessionsController
  def destroy
    refresh_token = current_user&.refresh_token
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))

    if signed_out
      keycloak_logout_url = build_keycloak_logout_url(refresh_token)
      redirect_to keycloak_logout_url, allow_other_host: true
    else
      redirect_to root_path
    end
  end

  private

  def build_keycloak_logout_url(refresh_token)
    base = "https://sso.piratenpartei.de/realms/Piratenlogin/protocol/openid-connect/logout"
    params = {
      post_logout_redirect_uri: root_url,
      client_id: ENV.fetch("KEYCLOAK_CLIENT_ID", "meine_piraten_de")
    }
    params[:refresh_token] = refresh_token if refresh_token.present?
    "#{base}?#{params.to_query}"
  end
end
