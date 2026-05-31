class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def show
    @course_count = Course.count
    @published_schedule_count = ClassSchedule.published.count
    @active_enrollment_count = Enrollment.active.count
    @draft_blog_post_count = BlogPost.draft.count
    @unread_contact_message_count = ContactMessage.unread.count
    @upcoming_schedules = ClassSchedule.upcoming.includes(:course).limit(5)
    @latest_registrations = Registration.includes(:class_schedule => :course).order(created_at: :desc).limit(5)

    # Visitor traffic statistics
    @today_visits = UniqueVisit.today.count
    @yesterday_visits = UniqueVisit.yesterday.count

    # 7-day visitor traffic history (padded with 0s for empty days)
    raw_visits = UniqueVisit.last_7_days.group(:visited_on).count
    @daily_visits_7_days = (6.days.ago.to_date..Date.today).map do |date|
      {
        date: date,
        count: raw_visits[date] || 0
      }
    end.reverse # Show latest dates first in history
  end
end
