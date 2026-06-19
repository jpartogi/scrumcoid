class Resources::DownloadRequestsController < ApplicationController
  before_action :set_resource

  def new
    @download_request = @resource.resource_download_requests.build
  end

  def create
    @download_request = @resource.resource_download_requests.build(download_request_params)

    if @download_request.save
      @download_request.send_download_email!

      redirect_to resource_path(@resource),
                  notice: "Terima kasih! Kami telah mengirim link download ke #{@download_request.visitor_email}. Silakan periksa kotak masuk Anda."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_resource
    @resource = Resource.published.find_by!(slug: params[:resource_id])

    return if @resource.available_for_email_download?

    redirect_to resource_path(@resource), alert: "Resource ini tidak tersedia untuk download via email." and return
  end

  def download_request_params
    params.require(:resource_download_request).permit(:visitor_name, :visitor_email, :job_title)
  end
end