require "test_helper"

class TaskNotificationTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  test "creating a task enqueues todo push notification" do
    assert_enqueued_with(job: PushNotificationJob) do
      Task.create!(
        title: "New task",
        category: categories(:wahlkampf),
        entity: entities(:kv_frankfurt),
        status: "open"
      )
    end
  end

  test "changing task status enqueues notification" do
    task = tasks(:wahlkampfmaterial)

    assert_enqueued_with(job: PushNotificationJob) do
      task.update!(status: "claimed", assignee_id: users(:pirat).id)
    end
  end

  test "changing task description does not enqueue notification" do
    task = tasks(:wahlkampfmaterial)

    assert_no_enqueued_jobs(only: PushNotificationJob) do
      task.update!(description: "Updated description only")
    end
  end
end
