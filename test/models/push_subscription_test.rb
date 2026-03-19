require "test_helper"

class PushSubscriptionTest < ActiveSupport::TestCase
  test "valid subscription" do
    sub = push_subscriptions(:pirat_device)
    assert sub.valid?
  end

  test "requires token" do
    sub = PushSubscription.new(user: users(:pirat), platform: "ios")
    assert_not sub.valid?
    assert_includes sub.errors[:token], "can't be blank"
  end

  test "requires unique token" do
    existing = push_subscriptions(:pirat_device)
    dup = PushSubscription.new(token: existing.token, user: users(:admin_pirat), platform: "ios")
    assert_not dup.valid?
    assert_includes dup.errors[:token], "has already been taken"
  end

  test "requires platform" do
    sub = PushSubscription.new(token: "unique-token-123", user: users(:pirat), platform: nil)
    assert_not sub.valid?
    assert_includes sub.errors[:platform], "can't be blank"
  end

  test "belongs to user" do
    sub = push_subscriptions(:pirat_device)
    assert_equal users(:pirat), sub.user
  end

  test "destroying user destroys subscriptions" do
    user = User.create!(provider: "openid_connect", uid: "temp-delete-test")
    PushSubscription.create!(token: "temp-token-for-delete-test", user: user, platform: "ios")

    assert_difference "PushSubscription.count", -1 do
      user.destroy
    end
  end
end
