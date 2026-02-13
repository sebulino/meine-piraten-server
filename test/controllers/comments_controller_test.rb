require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:wahlkampfmaterial)
  end

  EXPECTED_COMMENT_FIELDS = %w[
    id task_id author_name text created_at
  ].freeze

  # -- Index --

  test "GET /tasks/:task_id/comments.json returns array ordered by created_at" do
    get task_comments_url(@task, format: :json)
    assert_response :success

    json = JSON.parse(response.body)
    assert_instance_of Array, json
    assert json.size >= 2, "Expected at least 2 comments on wahlkampfmaterial task"

    EXPECTED_COMMENT_FIELDS.each do |field|
      assert json.first.key?(field), "Missing field: #{field}"
    end

    timestamps = json.map { |c| c["created_at"] }
    assert_equal timestamps, timestamps.sort, "Comments should be ordered by created_at ascending"
  end

  # -- Create --

  test "POST /tasks/:task_id/comments.json with valid params returns 201" do
    assert_difference("Comment.count") do
      post task_comments_url(@task, format: :json), params: {
        comment: {
          author_name: "pirat42",
          text: "Neuer Kommentar"
        }
      }
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Neuer Kommentar", json["text"]
    assert_equal @task.id, json["task_id"]
  end

  test "POST /tasks/:task_id/comments.json with empty text returns 422" do
    assert_no_difference("Comment.count") do
      post task_comments_url(@task, format: :json), params: {
        comment: {
          author_name: "pirat42",
          text: ""
        }
      }
    end

    assert_response :unprocessable_entity
  end

  # -- Destroy --

  test "DELETE /tasks/:task_id/comments/:id.json returns 204" do
    comment = comments(:samstag_mitbringen)

    assert_difference("Comment.count", -1) do
      delete task_comment_url(@task, comment, format: :json)
    end

    assert_response :no_content
  end
end
