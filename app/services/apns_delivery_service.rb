require "apnotic"

class ApnsDeliveryService
  INVALID_TOKEN_STATUSES = %w[400 403 404 410].freeze
  INVALID_TOKEN_REASONS  = %w[BadDeviceToken Unregistered ExpiredProviderToken].freeze

  class << self
    def send_notification(token:, payload:, badge: nil)
      instance.send_notification(token: token, payload: payload, badge: badge)
    end

    def instance
      @instance ||= new
    end

    def reset_connection!
      @instance&.close
      @instance = nil
    end
  end

  def initialize
    @key_path    = ENV.fetch("APNS_KEY_PATH")
    @key_id      = ENV.fetch("APNS_KEY_ID")
    @team_id     = ENV.fetch("APNS_TEAM_ID")
    @bundle_id   = ENV.fetch("APNS_BUNDLE_ID")
    @environment = ENV.fetch("APNS_ENVIRONMENT", "production")
    @mutex       = Mutex.new
  end

  def send_notification(token:, payload:, badge: nil)
    notification       = Apnotic::Notification.new(token)
    notification.topic = @bundle_id

    aps = payload[:aps] || {}
    notification.alert = aps[:alert] if aps[:alert]
    notification.sound = aps[:sound] if aps[:sound]
    notification.badge = badge unless badge.nil?

    custom = payload.except(:aps)
    notification.custom_payload = custom if custom.any?

    response = connection.push(notification)

    if response.nil?
      Rails.logger.error "APNs: timeout for #{token[0..7]}..."
      return { success: false, reason: "timeout" }
    end

    if response.ok?
      Rails.logger.info "APNs: delivered to #{token[0..7]}..."
      { success: true }
    else
      reason = response.body&.dig("reason")
      Rails.logger.warn "APNs: rejected #{token[0..7]}... (#{response.status}: #{reason})"

      if INVALID_TOKEN_REASONS.include?(reason)
        PushSubscription.where(token: token).destroy_all
        Rails.logger.info "APNs: removed stale token #{token[0..7]}..."
      end

      { success: false, reason: reason }
    end
  rescue StandardError => e
    Rails.logger.error "APNs: error (#{e.class}): #{e.message}"
    { success: false, reason: "error" }
  end

  def close
    @mutex.synchronize do
      @connection&.close
      @connection = nil
    end
  end

  private

  def connection
    @mutex.synchronize do
      @connection ||= build_connection
    end
  end

  def build_connection
    method = @environment == "production" ? :new : :development
    conn = Apnotic::Connection.public_send(method,
      auth_method: :token,
      cert_path: @key_path,
      key_id: @key_id,
      team_id: @team_id
    )
    conn.on(:error) do |e|
      Rails.logger.error "APNs connection error: #{e}"
    end
    conn
  end
end
