require "test_helper"

class HomeControllerTest < ActionDispatch::IntegrationTest
  test "homepage renders public trainer content" do
    get root_path

    assert_response :success
    assert_select "h1", /Kuasai Profesional Scrum/
    assert_select "footer", text: /Pelatihan Profesional Scrum/
    assert_select "a", text: "Sign in", count: 0
    assert_select "a", text: "Get Started", count: 0
    assert_select "a", text: "Admin dashboard", count: 0
    assert_no_match "scrum.co.id Admin", response.body
  end

  test "homepage shows admin dashboard link only for admins" do
    sign_in users(:admin)

    get root_path

    assert_response :success
    assert_select "a[href='#{admin_root_path}']", text: "Dasbor Admin"
  end
end
