require "test_helper"

class ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  test "shows contact form" do
    get new_contact_path

    assert_response :success
    assert_select "h1", /Diskusikan Kebutuhan/
  end

  test "creates contact message" do
    assert_difference -> { ContactMessage.count }, 1 do
      post contact_path, params: {
        contact_message: {
          name: "Pat Customer",
          email: "pat@example.com",
          company: "Customer Co",
          subject: "Training enquiry",
          message: "Can we discuss a private class?"
        }
      }
    end

    assert_redirected_to new_contact_path
    assert ContactMessage.last.unread?
  end
end
