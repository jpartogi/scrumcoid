class HomeController < ApplicationController
  def index
    @featured_schedules = ClassSchedule.available.includes(:class_schedule_prices, :course).limit(3)
    @recent_posts = BlogPost.recent.limit(3)
  end
end
