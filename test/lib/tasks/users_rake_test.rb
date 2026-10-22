require "test_helper"
require "rake"

class UsersRakeTest < ActiveSupport::TestCase
  setup do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
    @task = Rake::Task["users:make_superadmin"]
    @task.reenable
  end

  test "promotes an existing user to admin and superadmin" do
    user = users(:pirat)

    assert_output(/testpirat \(uid keycloak-uuid-1234\) is now admin \+ superadmin/) do
      @task.invoke("testpirat")
    end

    user.reload
    assert user.admin?
    assert user.superadmin?
  end

  test "is a no-op for an existing superadmin" do
    assert_output(/already superadmin/) do
      @task.invoke("superadminpirat")
    end
  end

  test "aborts for an unknown username" do
    error = assert_raises(SystemExit) do
      assert_output(nil, /No user 'nobody' found/) { @task.invoke("nobody") }
    end
    assert_not error.success?
  end

  test "aborts without a username" do
    assert_raises(SystemExit) do
      assert_output(nil, /Usage/) { @task.invoke }
    end
  end

  test "aborts when the username is ambiguous" do
    User.create!(provider: "openid_connect", uid: "other-uid", preferred_username: "testpirat")

    assert_raises(SystemExit) do
      assert_output(nil, /Multiple users named 'testpirat'/) { @task.invoke("testpirat") }
    end
    assert_not users(:pirat).reload.superadmin?
  end
end
