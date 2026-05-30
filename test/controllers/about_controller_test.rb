require "test_helper"

class AboutControllerTest < ActionDispatch::IntegrationTest
  test "shows public about page" do
    get about_path

    assert_response :success
    assert_select "h1", about_pages(:current).title
    assert_match "Pelatihan Scrum Profesional kami", response.body
  end
end
