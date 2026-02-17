ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "mocha/minitest"

OmniAuth.config.test_mode = true
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

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  private

  def admin_auth_headers
    admin_payload = {
      "sub" => "keycloak-uuid-admin",
      "email" => "admin@piratenpartei.de",
      "name" => "Admin Pirat",
      "preferred_username" => "adminpirat"
    }
    KeycloakTokenVerifier.stubs(:verify).with("admin-mock-token").returns(admin_payload)
    { "Authorization" => "Bearer admin-mock-token" }
  end

  def superadmin_auth_headers
    superadmin_payload = {
      "sub" => "keycloak-uuid-superadmin",
      "email" => "superadmin@piratenpartei.de",
      "name" => "Superadmin Pirat",
      "preferred_username" => "superadminpirat"
    }
    KeycloakTokenVerifier.stubs(:verify).with("superadmin-mock-token").returns(superadmin_payload)
    { "Authorization" => "Bearer superadmin-mock-token" }
  end

  def regular_auth_headers
    regular_payload = {
      "sub" => "keycloak-uuid-1234",
      "email" => "pirat@piratenpartei.de",
      "name" => "Test Pirat",
      "preferred_username" => "testpirat"
    }
    KeycloakTokenVerifier.stubs(:verify).with("mock-token").returns(regular_payload)
    { "Authorization" => "Bearer mock-token" }
  end
end
