class Admin::ResourcesController < ApplicationController
  INDEX_PER_PAGE = 10

  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_resource, only: [:show, :edit, :update, :destroy, :publish, :unpublish]

  def index
    sort_column    = %w[title published_at price].include?(params[:sort]) ? params[:sort] : "published_at"
    sort_direction = params[:direction] == "asc" ? "asc" : "desc"

    @sort_column    = sort_column
    @sort_direction = sort_direction

    resources = ordered_resources(sort_column, sort_direction)
    @resources = PaginatedScope.wrap(
      resources.with_attached_thumbnail.with_attached_file_attachment,
      page: params[:page],
      per_page: params[:per_page].presence || INDEX_PER_PAGE
    )
    resource_ids = @resources.map(&:id)
    @page_view_counts = PageView.unique_view_counts_for("Resource", resource_ids)
    @download_counts = ResourceDownloadRequest.download_counts_for(resource_ids)
  end

  def show
    @page_view_stats = @resource.page_view_stats
    @download_count = @resource.resource_download_requests.count
  end

  def new
    @resource = Resource.new(currency: Resource::DEFAULT_CURRENCY)
  end

  def edit
  end

  def create
    @resource = Resource.new(resource_params)

    if @resource.save(context: :admin_save)
      redirect_to admin_resource_path(@resource), notice: "Resource created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @resource.assign_attributes(resource_params)

    if @resource.save(context: :admin_save)
      redirect_to admin_resource_path(@resource), notice: "Resource updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @resource.destroy
    redirect_to admin_resources_path, notice: "Resource deleted."
  end

  def publish
    @resource.published!
    redirect_to admin_resource_path(@resource), notice: "Resource published."
  end

  def unpublish
    @resource.draft!
    redirect_to admin_resource_path(@resource), notice: "Resource unpublished."
  end

  private

  def ordered_resources(column, direction)
    scope = Resource.all

    if column == "published_at"
      if direction == "desc"
        scope.order(Arel.sql("published_at IS NULL")).order(published_at: :desc)
      else
        scope.order(Arel.sql("published_at IS NULL DESC")).order(published_at: :asc)
      end
    else
      scope.order(column => direction)
    end
  end

  def set_resource
    @resource = Resource.find_by!(slug: params[:id])
  end

  def resource_params
    params.require(:resource).permit(
      :title, :slug, :description, :meta_description, :meta_keywords, :tags,
      :page_count, :price, :currency, :published_at, :status, :thumbnail, :file_attachment
    )
  end
end