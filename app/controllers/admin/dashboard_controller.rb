class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def show
    @published_schedule_count = ClassSchedule.published.upcoming.count
    @active_enrollment_count = Enrollment.active.joins(:class_schedule).merge(ClassSchedule.upcoming).count
    @total_resource_downloads = ResourceDownloadRequest.count
    @upcoming_schedules = ClassSchedule.upcoming.includes(:course).limit(5)
    @latest_registrations = Registration.includes(:class_schedule => :course).order(created_at: :desc).limit(5)

    @reporting_timezone = UniqueVisit::REPORTING_TIMEZONE
    @reporting_timezone_abbr = UniqueVisit.reporting_zone.now.strftime("%Z")
    @reporting_today = UniqueVisit.reporting_today

    # Visitor traffic statistics (stored in UTC; displayed in Australia/Brisbane)
    @today_visits = UniqueVisit.today_count
    @yesterday_visits = UniqueVisit.yesterday_count
    @daily_visits_7_days = UniqueVisit.daily_counts(7)

    @unique_visitors_7d = UniqueVisit.distinct_visitors_in_days(7)
    @unique_visitors_30d = UniqueVisit.distinct_visitors_in_days(30)
    @total_retained_visitors = UniqueVisit.distinct.count(:fingerprint)

    @daily_visits_30_days = UniqueVisit.daily_counts(30)
    counts_30 = @daily_visits_30_days.map { |d| d[:count] }
    @avg_daily_visits_30d = counts_30.empty? ? 0 : (counts_30.sum.to_f / counts_30.size).round(1)
    @peak_daily_visits_30d = counts_30.max || 0
  end
end