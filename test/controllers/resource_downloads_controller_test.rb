require "test_helper"

class ResourceDownloadsControllerTest < ActionDispatch::IntegrationTest
  test "show redirects to attached file" do
    resource = resources(:free_resource)
    attach_sample_file(resource)
    request = resource_download_requests(:pending_download)

    get resource_download_path(request.token)
    assert_response :redirect
    assert_match %r{/rails/active_storage/}, response.redirect_url
  end

  test "show returns not found for invalid token" do
    get resource_download_path("invalid-token")
    assert_response :not_found
  end

  private

  def attach_sample_file(resource)
    record = Resource.find(resource.id)
    return if record.file_attachment.attached?

    record.file_attachment.attach(
      io: file_fixture("sample-resource.pdf").open,
      filename: "sample-resource.pdf",
      content_type: "application/pdf"
    )
  end
end