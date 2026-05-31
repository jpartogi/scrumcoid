require "test_helper"

class Admin::AdminEmailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @student = users(:student)
    @admin_email = AdminEmail.create!(email: "notify@example.com", main: true)
  end

  test "should require admin access for index" do
    sign_in @student
    get admin_admin_emails_path
    assert_redirected_to root_path
  end

  test "should get index when admin" do
    sign_in @admin
    get admin_admin_emails_path
    assert_response :success
    assert_select "h1", "Manage Admin Emails"
    assert_select "td", text: "notify@example.com"
  end

  test "should get new" do
    sign_in @admin
    get new_admin_admin_email_path
    assert_response :success
  end

  test "should create admin_email" do
    sign_in @admin
    assert_difference("AdminEmail.count") do
      post admin_admin_emails_path, params: { admin_email: { email: "new_admin@example.com", main: false } }
    end
    assert_redirected_to admin_admin_emails_path
    assert_equal "Admin email was successfully created.", flash[:notice]
  end

  test "should get edit" do
    sign_in @admin
    get edit_admin_admin_email_path(@admin_email)
    assert_response :success
  end

  test "should update admin_email" do
    sign_in @admin
    patch admin_admin_email_path(@admin_email), params: { admin_email: { email: "updated@example.com", main: false } }
    assert_redirected_to admin_admin_emails_path
    assert_equal "Admin email was successfully updated.", flash[:notice]
    @admin_email.reload
    assert_equal "updated@example.com", @admin_email.email
    assert_not @admin_email.main
  end

  test "should destroy admin_email" do
    sign_in @admin
    assert_difference("AdminEmail.count", -1) do
      delete admin_admin_email_path(@admin_email)
    end
    assert_redirected_to admin_admin_emails_path
    assert_equal "Admin email was successfully deleted.", flash[:notice]
  end
end
