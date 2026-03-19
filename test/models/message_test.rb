require "test_helper"

class MessageTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "valid message" do
    msg = messages(:from_admin_to_pirat)
    assert msg.valid?
  end

  test "requires body" do
    msg = Message.new(sender: users(:pirat), recipient: users(:admin_pirat))
    assert_not msg.valid?
    assert_includes msg.errors[:body], "can't be blank"
  end

  test "belongs to sender and recipient" do
    msg = messages(:from_admin_to_pirat)
    assert_equal users(:admin_pirat), msg.sender
    assert_equal users(:pirat), msg.recipient
  end

  test "creating a message enqueues push notification for recipient" do
    assert_enqueued_with(job: PushNotificationJob) do
      Message.create!(
        sender: users(:pirat),
        recipient: users(:admin_pirat),
        body: "Test message"
      )
    end
  end

  test "defaults read to false" do
    msg = Message.create!(
      sender: users(:pirat),
      recipient: users(:admin_pirat),
      body: "Unread message"
    )
    assert_not msg.read
  end
end
