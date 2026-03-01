require "test_helper"

class ChannelPostsCleanupJobTest < ActiveSupport::TestCase
  test "deletes posts older than 30 days" do
    old_post = ChannelPost.create!(chat_id: -1001, message_id: 1, posted_at: 31.days.ago, text: "old")
    recent_post = ChannelPost.create!(chat_id: -1001, message_id: 2, posted_at: 1.day.ago, text: "recent")

    ChannelPostsCleanupJob.perform_now

    assert_not ChannelPost.exists?(old_post.id)
    assert ChannelPost.exists?(recent_post.id)
  end
end
