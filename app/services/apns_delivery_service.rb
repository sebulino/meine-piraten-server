require "net/http"
require "json"
require "openssl"
require "jwt"

class ApnsDeliveryService
  APNS_PRODUCTION_URL = "https://api.push.apple.com"
  APNS_SANDBOX_URL    = "https://api.sandbox.push.apple.com"
  TOKEN_TTL = 50.minutes

  class DeliveryError < StandardError; end
  INVALID_TOKEN_REASONS = %w[BadDeviceToken Unregistered ExpiredProviderToken].freeze

  class << self
    def send_notification(token:, payload:)
      new.send_notification(token: token, payload: payload)
    end
  end

  def initialize
    @key_id    = ENV.fetch("APNS_KEY_ID")
    @team_id   = ENV.fetch("APNS_TEAM_ID")
    @bundle_id = ENV.fetch("APNS_BUNDLE_ID")
    @key_path  = ENV.fetch("APNS_KEY_PATH")
    @environment = ENV.fetch("APNS_ENVIRONMENT", "production")
  end

  def send_notification(token:, payload:)
    uri = URI("#{base_url}/3/device/#{token}")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request["authorization"] = "bearer #{provider_token}"
    request["apns-topic"] = @bundle_id
    request["apns-push-type"] = "alert"
    request["apns-priority"] = "10"
    request.body = payload.to_json

    response = http.request(request)

    case response.code.to_i
    when 200
      Rails.logger.info "APNs: delivered to #{token[0..7]}..."
      { success: true }
    when 400, 403, 404, 410
      body = JSON.parse(response.body) rescue {}
      reason = body["reason"]
      Rails.logger.warn "APNs: rejected token #{token[0..7]}... (#{reason})"

      if INVALID_TOKEN_REASONS.include?(reason)
        PushSubscription.where(token: token).destroy_all
        Rails.logger.info "APNs: removed stale token #{token[0..7]}..."
      end

      { success: false, reason: reason }
    else
      Rails.logger.error "APNs: unexpected response #{response.code} for #{token[0..7]}..."
      { success: false, reason: "http_#{response.code}" }
    end
  rescue Net::OpenTimeout, Net::ReadTimeout, SocketError, Errno::ECONNREFUSED => e
    Rails.logger.error "APNs: network error (#{e.class}): #{e.message}"
    { success: false, reason: "network_error" }
  end

  private

  def base_url
    @environment == "production" ? APNS_PRODUCTION_URL : APNS_SANDBOX_URL
  end

  def provider_token
    now = Time.now.to_i
    if @cached_token && @token_issued_at && (now - @token_issued_at) < TOKEN_TTL.to_i
      return @cached_token
    end

    key = OpenSSL::PKey::EC.new(File.read(@key_path))
    header = { kid: @key_id }
    claims = { iss: @team_id, iat: now }

    @token_issued_at = now
    @cached_token = JWT.encode(claims, key, "ES256", header)
  end
end
