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
  end
end
