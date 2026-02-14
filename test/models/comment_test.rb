require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "valid comment saves successfully" do
    comment = Comment.new(
      task: tasks(:wahlkampfmaterial),
      author_name: "pirat42",
      text: "Test comment"
    )
    assert comment.valid?, comment.errors.full_messages.join(", ")
  end

  test "comment without text is invalid" do
    comment = Comment.new(
      task: tasks(:wahlkampfmaterial),
      author_name: "pirat42",
      text: nil
    )
    assert_not comment.valid?
    assert_includes comment.errors[:text], "can't be blank"
  end
end
