require "test_helper"

class PushNotificationJobTest < ActiveSupport::TestCase
  test "sends to all news-enabled subscriptions for broadcast" do
    news_count = PushSubscription.where(news_enabled: true).count
    assert news_count > 0

    ApnsDeliveryService.expects(:send_notification).times(news_count).returns({ success: true })

    PushNotificationJob.perform_now(
      category: "news",
      extra: { deepLink: "forum" }
    )
  end

  test "sends only to targeted user for messages" do
    user = users(:pirat)
    user_msg_subs = PushSubscription.where(user: user, messages_enabled: true).count
    assert user_msg_subs > 0

    ApnsDeliveryService.expects(:send_notification).times(user_msg_subs).returns({ success: true })

    PushNotificationJob.perform_now(
      category: "messages",
      user_id: user.id,
      extra: { deepLink: "message", topicId: 42 }
    )
  end

  test "skips unknown category" do
    ApnsDeliveryService.expects(:send_notification).never

    PushNotificationJob.perform_now(category: "unknown")
  end

  test "does not send to users with category disabled" do
    # admin_pirat has forum_enabled: false
    admin = users(:admin_pirat)
    assert_not push_subscriptions(:admin_device).forum_enabled

    ApnsDeliveryService.expects(:send_notification).never

    PushNotificationJob.perform_now(
      category: "forum",
      user_id: admin.id,
      extra: { deepLink: "forum" }
    )
  end
end
