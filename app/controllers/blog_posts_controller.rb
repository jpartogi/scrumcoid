class BlogPostsController < ApplicationController
  def index
    @all_tags = BlogPost.all_tags
    scope = BlogPost.recent

    if params[:tag].present?
      @current_tag = params[:tag]
      scope = scope.with_tag(@current_tag)
    end

    per_page = params[:per_page] || (PaginatedScope.default_per_page == 20 ? 12 : PaginatedScope.default_per_page)
    @blog_posts = PaginatedScope.wrap(scope, page: params[:page], per_page: per_page)
  end

  def show
    @blog_post = BlogPost.published.find_by!(slug: params[:id])
    @related_posts = @blog_post.related_by_tags
  end
end
