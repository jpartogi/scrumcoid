class BlogPostsController < ApplicationController
  def index
    @all_tags = BlogPost.all_tags
    @blog_posts = BlogPost.recent
    return unless params[:tag].present?

    @current_tag = params[:tag]
    @blog_posts = @blog_posts.with_tag(@current_tag)
  end

  def show
    @blog_post = BlogPost.published.find_by!(slug: params[:id])
    @related_posts = @blog_post.related_by_tags
  end
end
