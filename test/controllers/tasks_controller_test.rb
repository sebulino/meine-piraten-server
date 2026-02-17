require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:wahlkampfmaterial)
    @claimed_task = tasks(:protokoll)
    @completed_task = tasks(:website_update)
  end

  EXPECTED_TASK_FIELDS = %w[
    id title description completed creator_name time_needed_in_hours
    due_date urgent activity_points category_id entity_id status
    assignee created_at updated_at url
  ].freeze

  # -- Index --

  test "GET /tasks.json returns array with correct fields" do
    get tasks_url(format: :json), headers: regular_auth_headers
    assert_response :success

    json = JSON.parse(response.body)
    assert_instance_of Array, json
    assert json.size >= 6, "Expected at least 6 tasks from fixtures"

    task_json = json.first
    EXPECTED_TASK_FIELDS.each do |field|
      assert task_json.key?(field), "Missing field: #{field}"
    end
  end

  test "GET /tasks.json without auth returns 401" do
    get tasks_url(format: :json)
    assert_response :unauthorized
  end

  # -- Show --

  test "GET /tasks/:id.json returns single task with all fields" do
    get task_url(@task, format: :json), headers: regular_auth_headers
    assert_response :success

    json = JSON.parse(response.body)
    EXPECTED_TASK_FIELDS.each do |field|
      assert json.key?(field), "Missing field: #{field}"
    end
    assert_equal @task.title, json["title"]
    assert_equal "open", json["status"]
  end

  # -- Create (admin only) --

  test "POST /tasks.json as admin returns 201" do
    assert_difference("Task.count") do
      post tasks_url(format: :json), params: {
        task: {
          title: "Neue Aufgabe",
          description: "Beschreibung",
          status: "open",
          category_id: categories(:wahlkampf).id,
          entity_id: entities(:kv_frankfurt).id,
          creator_name: "pirat42",
          activity_points: 5,
          time_needed_in_hours: 1
        }
      }, headers: admin_auth_headers
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Neue Aufgabe", json["title"]
    assert_equal "open", json["status"]
  end

  test "POST /tasks.json as regular user returns 403" do
    assert_no_difference("Task.count") do
      post tasks_url(format: :json), params: {
        task: {
          title: "Neue Aufgabe",
          status: "open",
          category_id: categories(:wahlkampf).id,
          entity_id: entities(:kv_frankfurt).id
        }
      }, headers: regular_auth_headers
    end

    assert_response :forbidden
  end

  test "POST /tasks.json with missing title returns 422" do
    assert_no_difference("Task.count") do
      post tasks_url(format: :json), params: {
        task: {
          title: "",
          status: "open",
          category_id: categories(:wahlkampf).id,
          entity_id: entities(:kv_frankfurt).id
        }
      }, headers: admin_auth_headers
    end

    assert_response :unprocessable_entity
  end

  # -- Update --

  test "PATCH /tasks/:id.json regular user can claim task (open to claimed)" do
    patch task_url(@task, format: :json), params: {
      task: { status: "claimed", assignee: "pirat42" }
    }, headers: regular_auth_headers

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "claimed", json["status"]
  end

  test "PATCH /tasks/:id.json regular user can unclaim task (claimed to open)" do
    patch task_url(@claimed_task, format: :json), params: {
      task: { status: "open" }
    }, headers: regular_auth_headers

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "open", json["status"]
  end

  test "PATCH /tasks/:id.json regular user can complete task (claimed to completed)" do
    patch task_url(@claimed_task, format: :json), params: {
      task: { status: "completed" }
    }, headers: regular_auth_headers

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "completed", json["status"]
  end

  test "PATCH /tasks/:id.json regular user cannot confirm done (completed to done)" do
    patch task_url(@completed_task, format: :json), params: {
      task: { status: "done" }
    }, headers: regular_auth_headers

    assert_response :forbidden
  end

  test "PATCH /tasks/:id.json admin can confirm done (completed to done)" do
    patch task_url(@completed_task, format: :json), params: {
      task: { status: "done" }
    }, headers: admin_auth_headers

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "done", json["status"]
  end

  test "PATCH /tasks/:id.json admin can revert completed to claimed" do
    patch task_url(@completed_task, format: :json), params: {
      task: { status: "claimed" }
    }, headers: admin_auth_headers

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "claimed", json["status"]
  end

  test "PATCH /tasks/:id.json with invalid status transition returns 422" do
    patch task_url(@task, format: :json), params: {
      task: { status: "done" }
    }, headers: admin_auth_headers

    assert_response :unprocessable_entity
  end

  # -- Destroy (admin only) --

  test "DELETE /tasks/:id.json as admin returns 204" do
    assert_difference("Task.count", -1) do
      delete task_url(@task, format: :json), headers: admin_auth_headers
    end

    assert_response :no_content
  end

  test "DELETE /tasks/:id.json as regular user returns 403" do
    assert_no_difference("Task.count") do
      delete task_url(@task, format: :json), headers: regular_auth_headers
    end

    assert_response :forbidden
  end
end
