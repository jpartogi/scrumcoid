require "test_helper"

class Admin::AboutPagesControllerTest < ActionDispatch::IntegrationTest
  test "admin can edit about page" do
    sign_in users(:admin)

    get edit_admin_about_page_path

    assert_response :success
    assert_select "h1", "Edit about page"
  end

  test "admin can update about page content" do
    sign_in users(:admin)

    patch admin_about_page_path, params: {
      about_page: {
        title: "About the Trainer",
        summary: "Updated summary.",
        body: "Updated rich text body."
      }
    }

    assert_redirected_to edit_admin_about_page_path
    assert_equal "About the Trainer", AboutPage.current.title
    assert_match "Updated rich text body", AboutPage.current.body.to_plain_text
  end
end
