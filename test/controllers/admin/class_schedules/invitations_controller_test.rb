require "test_helper"

class Admin::ClassSchedules::InvitationsControllerTest < ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper

  setup do
    @schedule = class_schedules(:open_online)
    @schedule.course.update!(invitation_email: "Halo {{full_name}}, see you in {{course_title}}.")
    @enrollment = enrollments(:existing_registration)
    @enrollment.update!(user: nil, first_name: "Jane", last_name: "Student", email: "jane@student.com")
    sign_in users(:admin)
  end

  test "admin can view invitation send page" do
    get new_admin_class_schedule_invitations_path(@schedule)
    assert_response :success
    assert_select "h1", "Send Invitation Emails"
    assert_select "input[name='enrollment_ids[]'][value='#{@enrollment.id}']"
  end

  test "admin sees warning when course template is missing" do
    @schedule.course.update!(invitation_email: nil)

    get new_admin_class_schedule_invitations_path(@schedule)
    assert_response :success
    assert_match "template is not configured", response.body
  end

  test "admin can queue invitation emails for selected students" do
    # Pre-set opened_at to test reset logic
    @enrollment.update!(invitation_opened_at: Time.current)

    assert_enqueued_emails 1 do
      post admin_class_schedule_invitations_path(@schedule), params: {
        subject: "Welcome to class",
        enrollment_ids: [@enrollment.id]
      }
    end

    assert_redirected_to admin_class_schedule_path(@schedule)
    assert_match "Invitation email queued", flash[:notice]
    
    @enrollment.reload
    assert_not_nil @enrollment.invitation_sent_at
    assert_nil @enrollment.invitation_opened_at
  end

  test "create requires at least one selected student" do
    assert_no_enqueued_emails do
      post admin_class_schedule_invitations_path(@schedule), params: {
        subject: "Welcome to class",
        enrollment_ids: []
      }
    end

    assert_redirected_to new_admin_class_schedule_invitations_path(@schedule)
    assert_match "Select at least one student", flash[:alert]
  end

  test "student cannot access invitation page" do
    sign_in users(:student)

    get new_admin_class_schedule_invitations_path(@schedule)
    assert_redirected_to root_path
  end
end