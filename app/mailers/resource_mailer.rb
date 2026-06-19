class ResourceMailer < ApplicationMailer
  helper ResourcesHelper

  def download_link(download_request)
    @download_request = download_request
    @resource = download_request.resource
    @download_url = resource_download_url(download_request.token)

    mail(
      to: download_request.visitor_email,
      subject: "Link download: #{@resource.title}"
    )
  end
end