class SitemapsController < ApplicationController
  skip_before_action :track_unique_visit, only: [:show]

  def show
    @courses = Course.published
    @class_schedules = ClassSchedule.available.includes(:course).order(:starts_at)
    @meetups = Meetup.published.order(:starts_at)
    @blog_posts = BlogPost.published
    @resources = Resource.published

    respond_to do |format|
      format.xml
    end
  end
end
