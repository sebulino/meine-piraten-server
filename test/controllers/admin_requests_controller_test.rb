require "test_helper"

class AdminRequestsControllerTest < ActionDispatch::IntegrationTest
  # -- Create (JSON API) --

  test "POST /admin_requests.json as authenticated user returns 201" do
    assert_difference("AdminRequest.count") do
      post admin_requests_url(format: :json),
        params: { reason: "Ich möchte Admin werden." },
        headers: regular_auth_headers
    end

    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "pending", json["status"]
    assert_equal "Ich möchte Admin werden.", json["reason"]
  end

  test "POST /admin_requests.json without auth returns 401" do
    assert_no_difference("AdminRequest.count") do
      post admin_requests_url(format: :json),
        params: { reason: "Test" }
    end

    assert_response :unauthorized
  end

  test "POST /admin_requests.json without reason returns 422" do
    assert_no_difference("AdminRequest.count") do
      post admin_requests_url(format: :json),
        params: { reason: "" },
        headers: regular_auth_headers
    end

    assert_response :unprocessable_entity
  end

  # -- Index (superadmin only, HTML) --

  test "GET /admin_requests as superadmin returns 200" do
    sign_in users(:superadmin_pirat)
    get admin_requests_url
    assert_response :success
  end

  test "GET /admin_requests as regular user redirects" do
    sign_in users(:pirat)
    get admin_requests_url
    assert_redirected_to root_path
  end

  test "GET /admin_requests as admin (non-super) redirects" do
    sign_in users(:admin_pirat)
    get admin_requests_url
    assert_redirected_to root_path
  end

  # -- Approve --

  test "PATCH /admin_requests/:id/approve as superadmin sets user admin" do
    request = admin_requests(:pending_request)
    user = request.user
    assert_not user.admin?

    sign_in users(:superadmin_pirat)
    patch approve_admin_request_url(request)

    request.reload
    user.reload
    assert_equal "approved", request.status
    assert user.admin?
    assert_not_nil request.reviewed_by
    assert_not_nil request.reviewed_at
    assert_redirected_to admin_requests_path
  end

  # -- Reject --

  test "PATCH /admin_requests/:id/reject as superadmin rejects request" do
    request = admin_requests(:pending_request)
    user = request.user

    sign_in users(:superadmin_pirat)
    patch reject_admin_request_url(request)

    request.reload
    user.reload
    assert_equal "rejected", request.status
    assert_not user.admin?
    assert_redirected_to admin_requests_path
  end

  # -- Authorization for approve/reject --

  test "PATCH /admin_requests/:id/approve as non-superadmin returns 403" do
    request = admin_requests(:pending_request)

    sign_in users(:admin_pirat)
    patch approve_admin_request_url(request)

    assert_redirected_to root_path
    request.reload
    assert_equal "pending", request.status
  end
end
