class CoursesController < ApplicationController
  def index
    @courses = Course.published.with_attached_logo.includes(:course_prices, :class_schedules).order(:title)
  end

  def show
    @course = Course.published.with_attached_logo.includes(:course_prices, :class_schedules).find_by!(slug: params[:id])
    @class_schedules = @course.class_schedules.available
    @related_blog_posts = @course.related_blog_posts
  end
end
