class UniqueVisit < ApplicationRecord
  REPORTING_TIMEZONE = "Australia/Brisbane"

  validates :fingerprint, :visited_at, :timezone, presence: true

  class << self
    def reporting_zone
      @reporting_zone ||= Time.find_zone!(REPORTING_TIMEZONE)
    end

    def reporting_today
      reporting_zone.today
    end

    def reporting_yesterday
      reporting_today - 1
    end

    def track!(fingerprint:, country: nil, referrer: nil)
      range = utc_range_for_reporting_date(reporting_today)
      visit = find_by(fingerprint: fingerprint, visited_at: range)
      return visit if visit

      create!(
        fingerprint: fingerprint,
        visited_at: Time.current,
        timezone: REPORTING_TIMEZONE,
        country: country,
        referrer: referrer
      )
    end

    def today_count
      on_reporting_date(reporting_today).count
    end

    def yesterday_count
      on_reporting_date(reporting_yesterday).count
    end

    def daily_counts(days)
      date_range = reporting_date_range(days)
      counts_by_date = count_visits_by_reporting_date(in_reporting_period(days), date_range)

      date_range.map do |date|
        { date: date, count: counts_by_date[date] }
      end.reverse
    end

    def distinct_visitors_in_days(days)
      in_reporting_period(days).distinct.count(:fingerprint)
    end

    def prune_old!(retention_days: 90)
      cutoff_date = reporting_today - retention_days
      cutoff_utc = utc_range_for_reporting_date(cutoff_date).first
      deleted = where("visited_at < ?", cutoff_utc).delete_all
      Rails.logger.info "Pruned #{deleted} old UniqueVisit records (retention: #{retention_days} days)" if deleted > 0
      deleted
    end

    def reporting_date_for(visited_at, timezone = REPORTING_TIMEZONE)
      visited_at.in_time_zone(timezone).to_date
    end

    def on_reporting_date(date)
      where(visited_at: utc_range_for_reporting_date(date))
    end

    def in_reporting_period(days)
      date_range = reporting_date_range(days)
      start_utc = utc_range_for_reporting_date(date_range.first).first
      end_utc = utc_range_for_reporting_date(date_range.last).last
      where(visited_at: start_utc..end_utc)
    end

    def utc_range_for_reporting_date(date)
      start_time = reporting_zone.local(date.year, date.month, date.day).beginning_of_day
      end_time = start_time.end_of_day
      start_time.utc..end_time.utc
    end

    private

    def reporting_date_range(days)
      end_date = reporting_today
      start_date = end_date - (days - 1)
      start_date..end_date
    end

    def count_visits_by_reporting_date(scope, date_range)
      counts = Hash.new(0)

      scope.pluck(:visited_at, :timezone).each do |visited_at, timezone|
        reporting_date = reporting_date_for(visited_at, timezone)
        counts[reporting_date] += 1 if date_range.cover?(reporting_date)
      end

      counts
    end
  end
end