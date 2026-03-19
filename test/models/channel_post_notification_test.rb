require "test_helper"

class ChannelPostNotificationTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  test "creating a channel post enqueues news push notification" do
    assert_enqueued_with(job: PushNotificationJob) do
      ChannelPost.create!(
        chat_id: -100999,
        message_id: 99999,
        posted_at: Time.current,
        text: "Test news post"
      )
    end
  end

  test "updating a channel post does not enqueue notification" do
    post = ChannelPost.create!(
      chat_id: -100999,
      message_id: 99998,
      posted_at: Time.current,
      text: "Original text"
    )

    assert_no_enqueued_jobs(only: PushNotificationJob) do
      post.update!(text: "Updated text")
    end
  end
end
