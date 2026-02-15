require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:wahlkampfmaterial)
    @auth_headers = { "Authorization" => "Bearer mock-token" }
    @token_payload = {
      "sub" => "keycloak-uuid-1234",
      "email" => "pirat@piratenpartei.de",
      "name" => "Test Pirat",
      "preferred_username" => "testpirat"
    }
    KeycloakTokenVerifier.stubs(:verify).with("mock-token").returns(@token_payload)
  end

  EXPECTED_TASK_FIELDS = %w[
    id title description completed creator_name time_needed_in_hours
    due_date urgent activity_points category_id entity_id status
    assignee created_at updated_at url
  ].freeze

  # -- Index --

  test "GET /tasks.json returns array with correct fields" do
    get tasks_url(format: :json), headers: @auth_headers
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
    get task_url(@task, format: :json), headers: @auth_headers
    assert_response :success

    json = JSON.parse(response.body)
    EXPECTED_TASK_FIELDS.each do |field|
      assert json.key?(field), "Missing field: #{field}"
    end
    assert_equal @task.title, json["title"]
    assert_equal "open", json["status"]
  end

  # -- Create --

  test "POST /tasks.json with valid params returns 201" do
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
      }, headers: @auth_headers
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "Neue Aufgabe", json["title"]
    assert_equal "open", json["status"]
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
      }, headers: @auth_headers
    end

    assert_response :unprocessable_entity
  end

  test "POST /tasks.json with title over 200 chars returns 422" do
    assert_no_difference("Task.count") do
      post tasks_url(format: :json), params: {
        task: {
          title: "a" * 201,
          status: "open",
          category_id: categories(:wahlkampf).id,
          entity_id: entities(:kv_frankfurt).id
        }
      }, headers: @auth_headers
    end

    assert_response :unprocessable_entity
  end

  # -- Update --

  test "PATCH /tasks/:id.json with valid status transition returns 200" do
    patch task_url(@task, format: :json), params: {
      task: { status: "claimed", assignee: "pirat42" }
    }, headers: @auth_headers

    assert_response :success
    json = JSON.parse(response.body)
    assert_equal "claimed", json["status"]
  end

  test "PATCH /tasks/:id.json with invalid status transition returns 422" do
    patch task_url(@task, format: :json), params: {
      task: { status: "done" }
    }, headers: @auth_headers

    assert_response :unprocessable_entity
  end

  # -- Destroy --

  test "DELETE /tasks/:id.json returns 204" do
    assert_difference("Task.count", -1) do
      delete task_url(@task, format: :json), headers: @auth_headers
    end

    assert_response :no_content
  end
end
