class SitemapsController < ApplicationController
  skip_before_action :track_unique_visit, only: [:show]

  def show
    @courses = Course.published
    @class_schedules = ClassSchedule.available.includes(:course).order(:starts_at)
    @blog_posts = BlogPost.published

    respond_to do |format|
      format.xml
    end
  end
end
