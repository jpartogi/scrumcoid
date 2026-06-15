require "test_helper"

class Admin::Courses::InvitationEmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = courses(:ai_essentials)
    sign_in users(:admin)
  end

  test "admin can view invitation email template form" do
    get edit_admin_course_invitation_email_path(@course)
    assert_response :success
    assert_select "h1", "Invitation Email Template"
    assert_select "input[type=hidden][name='course[invitation_email]']"
    assert_select "trix-editor"
  end

  test "admin can view invitation email template show page" do
    get admin_course_invitation_email_path(@course)
    assert_response :success
    assert_select "h1", "Invitation Email Template"
  end

  test "admin can update invitation email template" do
    patch admin_course_invitation_email_path(@course), params: {
      course: {
        invitation_email: "Halo {{full_name}}, welcome to {{course_title}}."
      }
    }

    assert_redirected_to admin_course_invitation_email_path(@course)
    assert_equal "Halo {{full_name}}, welcome to {{course_title}}.", @course.reload.invitation_email.to_plain_text
  end

  test "student cannot access invitation email template form" do
    sign_in users(:student)

    get edit_admin_course_invitation_email_path(@course)
    assert_redirected_to root_path
  end
end