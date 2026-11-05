require "test_helper"

class AdminRequestTest < ActiveSupport::TestCase
  test "valid admin request" do
    request = AdminRequest.new(user: users(:admin_pirat), reason: "Ich brauche Admin-Rechte.")
    assert request.valid?
  end

  test "rejects a second pending request for the same user" do
    request = AdminRequest.new(user: users(:pirat), reason: "Nochmal.")
    assert_not request.valid?
    assert_includes request.errors[:base], "Es liegt bereits eine offene Anfrage vor."
  end

  test "allows a new request once the previous one was reviewed" do
    admin_requests(:pending_request).update!(status: "rejected")
    request = AdminRequest.new(user: users(:pirat), reason: "Neuer Versuch.")
    assert request.valid?
  end

  test "reviewing a pending request is not blocked by the uniqueness rule" do
    assert admin_requests(:pending_request).update(status: "approved")
  end

  test "requires reason" do
    request = AdminRequest.new(user: users(:pirat), reason: "")
    assert_not request.valid?
    assert_includes request.errors[:reason], "can't be blank"
  end

  test "validates status inclusion" do
    request = AdminRequest.new(user: users(:pirat), reason: "Test", status: "invalid")
    assert_not request.valid?
    assert_includes request.errors[:status], "is not included in the list"
  end

  test "pending scope returns only pending requests" do
    pending = AdminRequest.pending
    assert pending.all? { |r| r.status == "pending" }
    assert_includes pending, admin_requests(:pending_request)
    assert_not_includes pending, admin_requests(:approved_request)
  end
end
