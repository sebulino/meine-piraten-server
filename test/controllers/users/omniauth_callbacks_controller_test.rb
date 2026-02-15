require "test_helper"

class Users::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  test "successful openid_connect callback creates user and signs in" do
    # Use a different UID than the fixture so a new user is created
    OmniAuth.config.mock_auth[:openid_connect] = OmniAuth::AuthHash.new({
      provider: "openid_connect",
      uid: "new-keycloak-uuid-5678",
      info: {
        email: "neuer-pirat@piratenpartei.de",
        name: "Neuer Pirat",
        nickname: "neuerpirat",
        preferred_username: "neuerpirat"
      },
      credentials: {
        token: "mock-access-token",
        refresh_token: "mock-refresh-token",
        expires_at: 1.hour.from_now.to_i
      }
    })

    assert_difference("User.count") do
      post user_openid_connect_omniauth_callback_path
    end

    assert_redirected_to root_path

    # Restore default mock
    OmniAuth.config.mock_auth[:openid_connect] = OmniAuth::AuthHash.new({
      provider: "openid_connect",
      uid: "keycloak-uuid-1234",
      info: {
        email: "pirat@piratenpartei.de",
        name: "Test Pirat",
        nickname: "testpirat",
        preferred_username: "testpirat"
      },
      credentials: {
        token: "mock-access-token",
        refresh_token: "mock-refresh-token",
        expires_at: 1.hour.from_now.to_i
      }
    })
  end

  test "successful openid_connect callback updates existing user" do
    existing_user = users(:pirat)

    assert_no_difference("User.count") do
      post user_openid_connect_omniauth_callback_path
    end

    assert_redirected_to root_path
    existing_user.reload
    assert_equal "mock-refresh-token", existing_user.refresh_token
  end

  test "failed openid_connect callback redirects with alert" do
    OmniAuth.config.mock_auth[:openid_connect] = :invalid_credentials

    # OmniAuth failure redirects to /auth/failure which triggers our failure handler
    get "/users/auth/failure?message=invalid_credentials&strategy=openid_connect"

    assert_redirected_to root_path

    # Restore default mock
    OmniAuth.config.mock_auth[:openid_connect] = OmniAuth::AuthHash.new({
      provider: "openid_connect",
      uid: "keycloak-uuid-1234",
      info: {
        email: "pirat@piratenpartei.de",
        name: "Test Pirat",
        nickname: "testpirat",
        preferred_username: "testpirat"
      },
      credentials: {
        token: "mock-access-token",
        refresh_token: "mock-refresh-token",
        expires_at: 1.hour.from_now.to_i
      }
    })
  end
end
