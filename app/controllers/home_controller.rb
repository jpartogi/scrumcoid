class HomeController < ApplicationController
  def index
    @featured_schedules = ClassSchedule.available.includes(course: :course_prices).limit(3)
    @recent_posts = BlogPost.recent.limit(3)
  end
end
