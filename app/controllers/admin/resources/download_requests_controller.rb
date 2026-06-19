class Admin::Resources::DownloadRequestsController < ApplicationController
  INDEX_PER_PAGE = 20

  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_resource

  def index
    @download_requests = PaginatedScope.wrap(
      @resource.resource_download_requests.order(created_at: :desc),
      page: params[:page],
      per_page: params[:per_page].presence || INDEX_PER_PAGE
    )
  end

  private

  def set_resource
    @resource = Resource.find_by!(slug: params[:resource_id])
  end
end