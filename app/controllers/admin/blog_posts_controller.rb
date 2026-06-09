class Admin::BlogPostsController < ApplicationController
  INDEX_PER_PAGE = 10

  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_blog_post, only: [:show, :edit, :update, :destroy, :publish, :unpublish]

  def index
    sort_column    = %w[title published_at].include?(params[:sort]) ? params[:sort] : "published_at"
    sort_direction = params[:direction] == "asc" ? "asc" : "desc"

    @sort_column    = sort_column
    @sort_direction = sort_direction

    @blog_posts = PaginatedScope.wrap(
      ordered_blog_posts(sort_column, sort_direction),
      page: params[:page],
      per_page: params[:per_page].presence || INDEX_PER_PAGE
    )
  end

  def show
  end

  def new
    @blog_post = BlogPost.new
  end

  def edit
  end

  def create
    @blog_post = BlogPost.new(blog_post_params)

    if @blog_post.save
      redirect_to admin_blog_post_path(@blog_post), notice: "Blog post created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @blog_post.update(blog_post_params)
      redirect_to admin_blog_post_path(@blog_post), notice: "Blog post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog_post.destroy
    redirect_to admin_blog_posts_path, notice: "Blog post deleted."
  end

  def publish
    @blog_post.published!
    redirect_to admin_blog_post_path(@blog_post), notice: "Blog post published."
  end

  def unpublish
    @blog_post.draft!
    redirect_to admin_blog_post_path(@blog_post), notice: "Blog post unpublished."
  end

  private

  def ordered_blog_posts(column, direction)
    scope = BlogPost.all

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

  def set_blog_post
    @blog_post = BlogPost.find_by!(slug: params[:id])
  end

  def blog_post_params
    params.require(:blog_post).permit(:title, :slug, :excerpt, :body, :published_at, :status, :meta_keywords, :tags)
  end
end
