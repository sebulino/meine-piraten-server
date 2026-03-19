require "test_helper"

class Api::MessagesControllerTest < ActionDispatch::IntegrationTest
  test "returns 401 without auth" do
    get api_messages_url, as: :json
    assert_response :unauthorized
  end

  test "index returns received messages for current user" do
    get api_messages_url, headers: regular_auth_headers, as: :json
    assert_response :ok

    json = JSON.parse(response.body)
    assert_instance_of Array, json
    assert json.size >= 1

    # pirat receives from admin_pirat
    msg = json.first
    assert msg.key?("id")
    assert msg.key?("body")
    assert msg.key?("read")
    assert msg.key?("created_at")
    assert msg.key?("sender_id")
  end

  test "create sends a message" do
    assert_difference "Message.count", 1 do
      post api_messages_url,
        params: { recipient_id: users(:admin_pirat).id, body: "Hello admin!" },
        headers: regular_auth_headers,
        as: :json
    end
    assert_response :created

    json = JSON.parse(response.body)
    assert json["id"].present?

    msg = Message.find(json["id"])
    assert_equal users(:pirat), msg.sender
    assert_equal users(:admin_pirat), msg.recipient
    assert_equal "Hello admin!", msg.body
  end

  test "create with missing body returns 422" do
    assert_no_difference "Message.count" do
      post api_messages_url,
        params: { recipient_id: users(:admin_pirat).id, body: "" },
        headers: regular_auth_headers,
        as: :json
    end
    assert_response :unprocessable_entity
  end

  test "update marks message as read" do
    msg = messages(:from_admin_to_pirat)
    assert_not msg.read

    patch api_message_url(msg),
      headers: regular_auth_headers,
      as: :json
    assert_response :ok

    msg.reload
    assert msg.read
  end

  test "update returns 404 for messages not addressed to current user" do
    msg = messages(:from_pirat_to_admin)

    patch api_message_url(msg),
      headers: regular_auth_headers,
      as: :json
    assert_response :not_found
  end
end
