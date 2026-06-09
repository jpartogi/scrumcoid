class Admin::DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!

  def show
    @published_schedule_count = ClassSchedule.published.count
    @active_enrollment_count = Enrollment.active.count
    @unread_contact_message_count = ContactMessage.unread.count
    @upcoming_schedules = ClassSchedule.upcoming.includes(:course).limit(5)
    @latest_registrations = Registration.includes(:class_schedule => :course).order(created_at: :desc).limit(5)

    # Visitor traffic statistics (cookie-based visitor IDs preferred; falls back to IP)
    @today_visits = UniqueVisit.today.count
    @yesterday_visits = UniqueVisit.yesterday.count

    # 7-day visitor traffic history (padded with 0s for empty days)
    raw_visits = UniqueVisit.last_7_days.group(:visited_on).count
    @daily_visits_7_days = ((Date.today - 6)..Date.today).map do |date|
      {
        date: date,
        count: raw_visits[date] || 0
      }
    end.reverse # Show latest dates first in history

    # --- More stats (expanded unique visitor metrics) ---
    last_7_range = (Date.today - 6)..Date.today
    last_30_range = (Date.today - 29)..Date.today

    @unique_visitors_7d = UniqueVisit.distinct_count_in_range(last_7_range)
    @unique_visitors_30d = UniqueVisit.distinct_count_in_range(last_30_range)
    @total_retained_visitors = UniqueVisit.distinct.count(:fingerprint)

    # 30-day daily data + derived stats (avg / peak)
    raw_30 = UniqueVisit.last_30_days.group(:visited_on).count
    @daily_visits_30_days = ((Date.today - 29)..Date.today).map do |date|
      { date: date, count: raw_30[date] || 0 }
    end.reverse

    counts_30 = @daily_visits_30_days.map { |d| d[:count] }
    @avg_daily_visits_30d = counts_30.empty? ? 0 : (counts_30.sum.to_f / counts_30.size).round(1)
    @peak_daily_visits_30d = counts_30.max || 0
  end
end
