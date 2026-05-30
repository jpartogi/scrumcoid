class Admin::BlogPostsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_blog_post, only: [:show, :edit, :update, :destroy, :publish, :unpublish]

  def index
    @blog_posts = BlogPost.order(created_at: :desc)
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

  def set_blog_post
    @blog_post = BlogPost.find_by!(slug: params[:id])
  end

  def blog_post_params
    params.require(:blog_post).permit(:title, :slug, :excerpt, :body, :published_at, :status)
  end
end
