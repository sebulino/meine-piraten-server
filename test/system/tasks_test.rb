require "application_system_test_case"

class TasksTest < ApplicationSystemTestCase
  setup do
    @task = tasks(:one)
  end

  test "visiting the index" do
    visit tasks_url
    assert_selector "h1", text: "Tasks"
  end

  test "should create task" do
    visit tasks_url
    click_on "New task"

    fill_in "Activity points", with: @task.activity_points
    fill_in "Category", with: @task.category_id
    check "Completed" if @task.completed
    fill_in "Creator name", with: @task.creator_name
    fill_in "Description", with: @task.description
    fill_in "Entity", with: @task.entity_id
    fill_in "Time needed in hours", with: @task.time_needed_in_hours
    fill_in "Title", with: @task.title
    click_on "Create Task"

    assert_text "Task was successfully created"
    click_on "Back"
  end

  test "should update Task" do
    visit task_url(@task)
    click_on "Edit this task", match: :first

    fill_in "Activity points", with: @task.activity_points
    fill_in "Category", with: @task.category_id
    check "Completed" if @task.completed
    fill_in "Creator name", with: @task.creator_name
    fill_in "Description", with: @task.description
    fill_in "Entity", with: @task.entity_id
    fill_in "Time needed in hours", with: @task.time_needed_in_hours
    fill_in "Title", with: @task.title
    click_on "Update Task"

    assert_text "Task was successfully updated"
    click_on "Back"
  end

  test "should destroy Task" do
    visit task_url(@task)
    click_on "Destroy this task", match: :first

    assert_text "Task was successfully destroyed"
  end
end
