class ResourceDownloadsController < ApplicationController
  def show
    @download_request = ResourceDownloadRequest.find_by!(token: params[:token])
    @resource = @download_request.resource

    unless @resource.published? && @resource.file_attachment.attached?
      raise ActiveRecord::RecordNotFound
    end

    redirect_to rails_blob_url(@resource.file_attachment, disposition: "attachment"), allow_other_host: true
  end
end