require "test_helper"

class ChannelPostTest < ActiveSupport::TestCase
  test "recent scope includes posts from 29 days ago" do
    post = ChannelPost.create!(chat_id: -1001, message_id: 1, posted_at: 29.days.ago, text: "recent")
    assert_includes ChannelPost.recent, post
  end

  test "recent scope excludes posts older than 30 days" do
    post = ChannelPost.create!(chat_id: -1001, message_id: 2, posted_at: 31.days.ago, text: "old")
    assert_not_includes ChannelPost.recent, post
  end
end
