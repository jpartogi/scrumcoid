require "test_helper"

class Resources::DownloadRequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @resource = resources(:free_resource)
    attach_sample_file(@resource)
  end

  test "new renders download request form with privacy notice" do
    get new_resource_download_request_path(@resource)
    assert_response :success
    assert_match "Privasi email Anda aman", response.body
    assert_match "tidak akan mengirim spam", response.body
    assert_match "tidak akan menjual data Anda", response.body
    assert_match "internal continuous improvement", response.body
    assert_select "select[name='resource_download_request[job_title]']"
  end

  test "create sends download request and redirects with notice" do
    assert_enqueued_emails 1 do
      assert_difference("ResourceDownloadRequest.count") do
        post resource_download_requests_path(@resource), params: {
          resource_download_request: {
            visitor_name: "Ani Wijaya",
            visitor_email: "ani@example.com",
            job_title: "business_analyst"
          }
        }
      end
    end

    assert_redirected_to resource_path(@resource)
    follow_redirect!
    assert_match "ani@example.com", response.body

    request = ResourceDownloadRequest.order(:id).last
    assert_equal "Ani Wijaya", request.visitor_name
    assert_equal "business_analyst", request.job_title
  end

  test "redirects when resource is not available for email download" do
    paid = resources(:published_resource)
    get new_resource_download_request_path(paid)
    assert_redirected_to resource_path(paid)
    assert_equal "Resource ini tidak tersedia untuk download via email.", flash[:alert]
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