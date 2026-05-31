require "test_helper"

class EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @user = users(:student)
    @schedule = class_schedules(:open_online)
    @enrollment = enrollments(:existing_registration)
  end

  test "authenticated user can cancel their enrollment" do
    sign_in @user

    assert_changes -> { @enrollment.reload.status }, from: "active", to: "cancelled" do
      delete class_schedule_enrollment_path(@schedule)
    end

    assert_redirected_to dashboard_path
    assert_equal "Your registration was cancelled.", flash[:notice]
  end

  test "unauthenticated visitor is redirected to sign in when trying to cancel" do
    assert_no_changes -> { @enrollment.reload.status } do
      delete class_schedule_enrollment_path(@schedule)
    end

    assert_redirected_to new_user_session_path
  end
end
