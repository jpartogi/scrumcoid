require "test_helper"

class Devise::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "admin can edit name from account settings" do
    sign_in users(:admin)

    get edit_user_registration_path

    assert_response :success
    assert_select "input[name='user[name]']"

    put user_registration_path, params: {
      user: {
        name: "Updated Admin",
        email: users(:admin).email,
        current_password: "password123"
      }
    }

    assert_redirected_to root_path
    assert_equal "Updated Admin", users(:admin).reload.name
  end
end
