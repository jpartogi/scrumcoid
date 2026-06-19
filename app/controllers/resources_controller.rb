class ResourcesController < ApplicationController
  def index
    @all_tags = Resource.all_tags
    scope = Resource.recent.with_attached_thumbnail.with_attached_file_attachment

    if params[:tag].present?
      @current_tag = params[:tag]
      scope = scope.with_tag(@current_tag)
    end

    per_page = params[:per_page] || (PaginatedScope.default_per_page == 20 ? 12 : PaginatedScope.default_per_page)
    @resources = PaginatedScope.wrap(scope, page: params[:page], per_page: per_page)
  end

  def show
    @resource = Resource.published.with_attached_thumbnail.with_attached_file_attachment.find_by!(slug: params[:id])
    @related_resources = @resource.related_resources
    track_page_view(@resource)
  end
end