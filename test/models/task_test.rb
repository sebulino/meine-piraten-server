require "test_helper"

class TaskTest < ActiveSupport::TestCase
  # -- Validation tests --

  test "valid task saves successfully" do
    task = Task.new(
      title: "Test task",
      description: "A description",
      status: "open",
      category: categories(:wahlkampf),
      entity: entities(:kv_frankfurt)
    )
    assert task.valid?, task.errors.full_messages.join(", ")
  end

  test "task without title is invalid" do
    task = tasks(:wahlkampfmaterial)
    task.title = nil
    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "task with title over 200 chars is invalid" do
    task = tasks(:wahlkampfmaterial)
    task.title = "a" * 201
    assert_not task.valid?
    assert task.errors[:title].any? { |msg| msg.include?("200") }
  end

  test "task with description over 2000 chars is invalid" do
    task = tasks(:wahlkampfmaterial)
    task.description = "a" * 2001
    assert_not task.valid?
    assert task.errors[:description].any? { |msg| msg.include?("2000") }
  end

  test "task with invalid status is invalid" do
    task = tasks(:wahlkampfmaterial)
    task.status = "invalid"
    assert_not task.valid?
    assert_includes task.errors[:status], "is not included in the list"
  end

  test "task with nil description is valid" do
    task = tasks(:pressemitteilung)
    task.description = nil
    assert task.valid?
  end

  # -- Status transition tests --

  test "open to claimed is valid" do
    task = tasks(:wahlkampfmaterial)
    assert_equal "open", task.status
    task.status = "claimed"
    assert task.valid?, task.errors.full_messages.join(", ")
  end

  test "claimed to completed is valid" do
    task = tasks(:protokoll)
    assert_equal "claimed", task.status
    task.status = "completed"
    assert task.valid?, task.errors.full_messages.join(", ")
  end

  test "completed to done is valid" do
    task = tasks(:website_update)
    assert_equal "completed", task.status
    task.status = "done"
    assert task.valid?, task.errors.full_messages.join(", ")
  end

  test "completed to claimed is valid" do
    task = tasks(:website_update)
    assert_equal "completed", task.status
    task.status = "claimed"
    assert task.valid?, task.errors.full_messages.join(", ")
  end

  test "claimed to open is valid" do
    task = tasks(:protokoll)
    assert_equal "claimed", task.status
    task.status = "open"
    assert task.valid?, task.errors.full_messages.join(", ")
  end

  test "claimed to done is invalid" do
    task = tasks(:protokoll)
    assert_equal "claimed", task.status
    task.status = "done"
    assert_not task.valid?
    assert task.errors[:status].any? { |msg| msg.include?("cannot transition") }
  end

  test "open to done is invalid" do
    task = tasks(:wahlkampfmaterial)
    assert_equal "open", task.status
    task.status = "done"
    assert_not task.valid?
    assert task.errors[:status].any? { |msg| msg.include?("cannot transition") }
  end

  test "open to completed is invalid" do
    task = tasks(:wahlkampfmaterial)
    assert_equal "open", task.status
    task.status = "completed"
    assert_not task.valid?
    assert task.errors[:status].any? { |msg| msg.include?("cannot transition") }
  end

  test "done to open is invalid" do
    task = tasks(:newsletter)
    assert_equal "done", task.status
    task.status = "open"
    assert_not task.valid?
    assert task.errors[:status].any? { |msg| msg.include?("cannot transition") }
  end

  test "done to claimed is invalid" do
    task = tasks(:newsletter)
    assert_equal "done", task.status
    task.status = "claimed"
    assert_not task.valid?
    assert task.errors[:status].any? { |msg| msg.include?("cannot transition") }
  end
end
