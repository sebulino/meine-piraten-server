require "test_helper"

class Api::PushSubscriptionsControllerTest < ActionDispatch::IntegrationTest
  test "returns 401 without auth header" do
    post api_push_subscriptions_url, params: { token: "abc123" }, as: :json
    assert_response :unauthorized
  end

  test "creates a new subscription" do
    assert_difference "PushSubscription.count", 1 do
      post api_push_subscriptions_url,
        params: { token: "new-device-token-xyz", platform: "ios", messages: true, news: true },
        headers: regular_auth_headers,
        as: :json
    end
    assert_response :ok

    sub = PushSubscription.find_by(token: "new-device-token-xyz")
    assert sub.present?
    assert_equal "ios", sub.platform
    assert sub.messages_enabled
    assert_not sub.todos_enabled
    assert_not sub.forum_enabled
    assert sub.news_enabled
  end

  test "upserts existing subscription by token" do
    existing = push_subscriptions(:pirat_device)
    assert_not existing.todos_enabled

    assert_no_difference "PushSubscription.count" do
      post api_push_subscriptions_url,
        params: { token: existing.token, platform: "ios", todos: true },
        headers: regular_auth_headers,
        as: :json
    end
    assert_response :ok

    existing.reload
    assert existing.todos_enabled
  end

  test "destroy removes subscription" do
    existing = push_subscriptions(:pirat_device)

    assert_difference "PushSubscription.count", -1 do
      delete api_push_subscription_url(token: existing.token),
        headers: regular_auth_headers,
        as: :json
    end
    assert_response :ok
  end

  test "destroy with unknown token returns 200" do
    assert_no_difference "PushSubscription.count" do
      delete api_push_subscription_url(token: "nonexistent-token"),
        headers: regular_auth_headers,
        as: :json
    end
    assert_response :ok
  end

  test "destroy returns 401 without auth" do
    existing = push_subscriptions(:pirat_device)
    delete api_push_subscription_url(token: existing.token), as: :json
    assert_response :unauthorized
  end
end
