require "application_system_test_case"

class AdminRequestsTest < ApplicationSystemTestCase
  test "admin without superadmin rights does not see admin requests" do
    sign_in users(:admin_pirat)
    visit tasks_url

    assert_no_link "Admin-Anfragen"
  end

  test "superadmin approves a pending request" do
    sign_in users(:superadmin_pirat)
    visit tasks_url
    click_on "Admin-Anfragen"

    assert_text admin_requests(:pending_request).reason
    click_on "Zum Admin befördern"

    assert_text "Anfrage genehmigt. testpirat ist jetzt Admin."
    assert_text "Keine offenen Anfragen."
  end

  test "superadmin rejects a pending request" do
    sign_in users(:superadmin_pirat)
    visit admin_requests_url
    click_on "Ablehnen"

    assert_text "Anfrage abgelehnt."
    assert_text "Keine offenen Anfragen."
  end
end
