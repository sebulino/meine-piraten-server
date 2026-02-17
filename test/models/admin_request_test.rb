require "test_helper"

class AdminRequestTest < ActiveSupport::TestCase
  test "valid admin request" do
    request = AdminRequest.new(user: users(:pirat), reason: "Ich brauche Admin-Rechte.")
    assert request.valid?
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
