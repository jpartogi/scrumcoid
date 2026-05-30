class BlogPostsController < ApplicationController
  def index
    @blog_posts = BlogPost.recent
  end

  def show
    @blog_post = BlogPost.published.find_by!(slug: params[:id])
  end
end
