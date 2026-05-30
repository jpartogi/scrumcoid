require "test_helper"

class Admin::DashboardControllerTest < ActionDispatch::IntegrationTest
  test "requires admin access" do
    sign_in users(:student)

    get admin_root_path

    assert_redirected_to root_path
  end

  test "allows admin access" do
    sign_in users(:admin)

    get admin_root_path

    assert_response :success
    assert_select "h1", "Admin dashboard"
    assert_select "#admin-nav-content", text: /#{users(:admin).name}/
    assert_select "a[href='#{edit_user_registration_path}']", text: "Account settings"
    assert_select "footer", text: /scrum.co.id Admin/
    assert_no_match "Professional Scrum training for teams", response.body
  end
end
