require "test_helper"

class KeycloakTokenVerifierTest < ActiveSupport::TestCase
  setup do
    @rsa_key = OpenSSL::PKey::RSA.generate(2048)
    @jwk = JWT::JWK.new(@rsa_key, kid: "test-key-id")
    @jwks = JWT::JWK::Set.new([@jwk])
  end

  test "verify decodes valid token" do
    token = JWT.encode(
      { "sub" => "user-123", "iss" => KeycloakTokenVerifier::ISSUER, "exp" => 1.hour.from_now.to_i },
      @rsa_key,
      "RS256",
      { kid: "test-key-id" }
    )

    KeycloakTokenVerifier.stubs(:fetch_jwks).returns(@jwks)
    # Clear cached JWKS
    KeycloakTokenVerifier.instance_variable_set(:@jwks, nil)
    KeycloakTokenVerifier.instance_variable_set(:@jwks_last_fetched, nil)

    payload = KeycloakTokenVerifier.verify(token)
    assert_equal "user-123", payload["sub"]
  end

  test "verify rejects expired token" do
    token = JWT.encode(
      { "sub" => "user-123", "iss" => KeycloakTokenVerifier::ISSUER, "exp" => 1.hour.ago.to_i },
      @rsa_key,
      "RS256",
      { kid: "test-key-id" }
    )

    KeycloakTokenVerifier.stubs(:fetch_jwks).returns(@jwks)
    KeycloakTokenVerifier.instance_variable_set(:@jwks, nil)
    KeycloakTokenVerifier.instance_variable_set(:@jwks_last_fetched, nil)

    assert_raises(JWT::ExpiredSignature) do
      KeycloakTokenVerifier.verify(token)
    end
  end

  test "verify rejects wrong issuer" do
    token = JWT.encode(
      { "sub" => "user-123", "iss" => "https://wrong-issuer.example.com", "exp" => 1.hour.from_now.to_i },
      @rsa_key,
      "RS256",
      { kid: "test-key-id" }
    )

    KeycloakTokenVerifier.stubs(:fetch_jwks).returns(@jwks)
    KeycloakTokenVerifier.instance_variable_set(:@jwks, nil)
    KeycloakTokenVerifier.instance_variable_set(:@jwks_last_fetched, nil)

    assert_raises(JWT::InvalidIssuerError) do
      KeycloakTokenVerifier.verify(token)
    end
  end
end
