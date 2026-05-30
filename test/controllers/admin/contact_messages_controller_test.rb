require "test_helper"

class Admin::ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  test "admin can list contact messages" do
    sign_in users(:admin)

    get admin_contact_messages_path

    assert_response :success
    assert_match contact_messages(:unread).subject, response.body
  end

  test "admin viewing message marks it read" do
    sign_in users(:admin)
    message = contact_messages(:unread)

    get admin_contact_message_path(message)

    assert_response :success
    assert message.reload.read?
  end

  test "student cannot access contact messages" do
    sign_in users(:student)

    get admin_contact_messages_path

    assert_redirected_to root_path
  end
end
