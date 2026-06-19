require "test_helper"

class Admin::ResourcesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    sign_in @admin
  end

  test "index lists resources" do
    get admin_resources_path
    assert_response :success
    assert_match resources(:published_resource).title, response.body
    assert_match resources(:draft_resource).title, response.body
  end

  test "index shows click and download counts for comparison" do
    free_resource = resources(:free_resource)
    PageView.track!(viewable: free_resource, fingerprint: "visitor-a")
    PageView.track!(viewable: free_resource, fingerprint: "visitor-b")

    get admin_resources_path
    assert_response :success
    assert_select "th", text: "Klik"
    assert_select "th", text: "Downloads"

    free_row = css_select("tr").find { |row| row.text.include?(free_resource.title) }
    assert free_row
    assert_includes free_row.text, "2"
    assert_includes free_row.text, "1"
  end

  test "show displays resource details" do
    resource = resources(:published_resource)
    get admin_resource_path(resource)
    assert_response :success
    assert_match resource.title, response.body
    assert_match resource.display_price, response.body
  end

  test "show links to download requests list" do
    resource = resources(:free_resource)
    get admin_resource_path(resource)
    assert_response :success
    assert_select "a[href=?]", admin_resource_download_requests_path(resource), text: /View Downloaders/
  end

  test "new renders form" do
    get new_admin_resource_path
    assert_response :success
    assert_select "form"
    assert_match "Create Resource", response.body
  end

  test "create resource with custom slug" do
    assert_difference("Resource.count") do
      post admin_resources_path, params: {
        resource: {
          title: "New Scrum Template",
          slug: "new-scrum-template",
          description: "<div>Template content</div>",
          meta_description: "A useful template",
          meta_keywords: "scrum, template",
          tags: "scrum",
          page_count: 10,
          price: 99000,
          currency: "IDR",
          status: "draft"
        }
      }
    end
    assert_redirected_to admin_resource_path(Resource.find_by!(slug: "new-scrum-template"))
  end

  test "create resource auto-generates slug from title when slug is blank" do
    assert_difference("Resource.count") do
      post admin_resources_path, params: {
        resource: {
          title: "Product Owner Toolkit",
          description: "<div>Toolkit content</div>",
          meta_description: "A useful toolkit",
          price: 0,
          currency: "IDR",
          status: "draft"
        }
      }
    end

    resource = Resource.find_by!(slug: "product-owner-toolkit")
    assert_redirected_to admin_resource_path(resource)
    assert_equal "Product Owner Toolkit", resource.title
  end

  test "publish resource" do
    resource = resources(:draft_resource)
    patch publish_admin_resource_path(resource)
    assert_redirected_to admin_resource_path(resource)
    assert resource.reload.published?
  end

  test "unpublish resource" do
    resource = resources(:published_resource)
    patch unpublish_admin_resource_path(resource)
    assert_redirected_to admin_resource_path(resource)
    assert resource.reload.draft?
  end

  test "requires admin authentication" do
    sign_out @admin
    get admin_resources_path
    assert_redirected_to new_user_session_path
  end
end