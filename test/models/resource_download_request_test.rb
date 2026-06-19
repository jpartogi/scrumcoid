require "test_helper"

class ResourceDownloadRequestTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess::FixtureFile
  setup do
    @resource = resources(:free_resource)
    attach_sample_file(@resource)
  end

  test "assigns token on create" do
    request = build_download_request
    request.valid?
    assert request.token.present?
  end

  test "validates job title inclusion" do
    request = build_download_request(job_title: nil)
    assert_not request.valid?
  end

  test "job_title_label returns human readable label" do
    request = resource_download_requests(:pending_download)
    assert_equal "Product Owner/Product Manager", request.job_title_label
  end

  test "rejects download request when resource is paid" do
    resource = resources(:published_resource)
    attach_sample_file(resource)

    request = ResourceDownloadRequest.new(
      resource: resource,
      visitor_name: "Test User",
      visitor_email: "test@example.com",
      job_title: :scrum_master_coach
    )

    assert_not request.valid?
    assert_includes request.errors[:resource], "is not available for email download"
  end

  private

  def build_download_request(attrs = {})
    ResourceDownloadRequest.new({
      resource: @resource,
      visitor_name: "Test User",
      visitor_email: "test@example.com",
      job_title: :product_owner_manager
    }.merge(attrs))
  end

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