require "test_helper"

class Admin::Resources::DownloadRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @resource = resources(:free_resource)
    @download_request = resource_download_requests(:pending_download)
    sign_in @admin
  end

  test "index lists download requests for resource" do
    get admin_resource_download_requests_path(@resource)
    assert_response :success
    assert_match @download_request.visitor_name, response.body
    assert_match @download_request.visitor_email, response.body
    assert_match @download_request.job_title_label, response.body
  end

  test "index shows empty state when no download requests" do
    resource = resources(:published_resource)
    get admin_resource_download_requests_path(resource)
    assert_response :success
    assert_match "No download requests yet", response.body
  end

  test "requires admin authentication" do
    sign_out @admin
    get admin_resource_download_requests_path(@resource)
    assert_redirected_to new_user_session_path
  end
end