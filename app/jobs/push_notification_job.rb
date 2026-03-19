class PushNotificationJob < ApplicationJob
  queue_as :default

  ALERT_TEXTS = {
    messages: { title: "PIRATEN App", body: "Du hast eine neue Nachricht" },
    todos:    { title: "PIRATEN App", body: "Ein ToDo wurde aktualisiert" },
    forum:    { title: "PIRATEN App", body: "Es gibt neue Beiträge im Forum" },
    news:     { title: "PIRATEN App", body: "Es gibt neue Neuigkeiten" }
  }.freeze

  # @param category [String] one of "messages", "todos", "forum", "news"
  # @param user_id [Integer, nil] target user (nil = broadcast to all matching)
  # @param extra [Hash] additional payload keys (deepLink, topicId, etc.)
  def perform(category:, user_id: nil, extra: {})
    category_sym = category.to_sym
    alert = ALERT_TEXTS[category_sym]
    unless alert
      Rails.logger.error "PushNotificationJob: unknown category '#{category}'"
      return
    end

    enabled_column = :"#{category}_enabled"
    scope = PushSubscription.where(enabled_column => true)
    scope = scope.where(user_id: user_id) if user_id

    payload = {
      aps: {
        alert: alert,
        sound: "default"
      }
    }.merge(extra)

    delivered = 0
    scope.find_each do |sub|
      badge = unread_badge_count(sub.user_id)
      result = ApnsDeliveryService.send_notification(token: sub.token, payload: payload, badge: badge)
      delivered += 1 if result[:success]
    end

    Rails.logger.info "PushNotificationJob: #{category} — delivered #{delivered}/#{scope.count}"
  end

  private

  def unread_badge_count(user_id)
    Message.where(recipient_id: user_id, read: false).count
  end
end
