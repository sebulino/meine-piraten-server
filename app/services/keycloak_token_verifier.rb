class KeycloakTokenVerifier
  ISSUER = "https://sso.piratenpartei.de/realms/Piratenlogin"
  JWKS_URL = "#{ISSUER}/protocol/openid-connect/certs"
  JWKS_CACHE_TTL = 1.hour

  class << self
    def verify(token)
      JWT.decode(token, nil, true, {
        algorithms: ["RS256"],
        iss: ISSUER,
        verify_iss: true,
        jwks: jwks_loader
      }).first
    end

    private

    def jwks_loader
      ->(options) {
        @jwks = nil if options[:invalidate] || jwks_expired?
        @jwks_last_fetched = Time.current if @jwks.nil?
        @jwks ||= fetch_jwks
      }
    end

    def jwks_expired?
      @jwks_last_fetched && Time.current - @jwks_last_fetched > JWKS_CACHE_TTL
    end

    def fetch_jwks
      response = Net::HTTP.get(URI(JWKS_URL))
      JWT::JWK::Set.new(JSON.parse(response))
    end
  end
end
