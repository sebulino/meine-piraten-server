require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @task = tasks(:one)
  end

  test "should get index" do
    get tasks_url
    assert_response :success
  end

  test "should get new" do
    get new_task_url
    assert_response :success
  end

  test "should create task" do
    assert_difference("Task.count") do
      post tasks_url, params: { task: { activity_points: @task.activity_points, category_id: @task.category_id, completed: @task.completed, creator_name: @task.creator_name, description: @task.description, entity_id: @task.entity_id, time_needed_in_hours: @task.time_needed_in_hours, title: @task.title } }
    end

    assert_redirected_to task_url(Task.last)
  end

  test "should show task" do
    get task_url(@task)
    assert_response :success
  end

  test "should get edit" do
    get edit_task_url(@task)
    assert_response :success
  end

  test "should update task" do
    patch task_url(@task), params: { task: { activity_points: @task.activity_points, category_id: @task.category_id, completed: @task.completed, creator_name: @task.creator_name, description: @task.description, entity_id: @task.entity_id, time_needed_in_hours: @task.time_needed_in_hours, title: @task.title } }
    assert_redirected_to task_url(@task)
  end

  test "should destroy task" do
    assert_difference("Task.count", -1) do
      delete task_url(@task)
    end

    assert_redirected_to tasks_url
  end
end
