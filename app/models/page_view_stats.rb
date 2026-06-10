class PageViewStats
  attr_reader :viewable

  def initialize(viewable)
    @viewable = viewable
    @scope = PageView.where(viewable: viewable)
  end

  def today_count
    @scope.today.count
  end

  def yesterday_count
    @scope.yesterday.count
  end

  def daily_visits_7_days
    padded_daily_counts(@scope.last_7_days, (Date.today - 6)..Date.today)
  end

  def unique_visitors_7d
    PageView.distinct_count_in_range(viewable: viewable, range: last_7_range)
  end

  def unique_visitors_30d
    PageView.distinct_count_in_range(viewable: viewable, range: last_30_range)
  end

  def total_unique_views
    @scope.distinct.count(:fingerprint)
  end

  def avg_daily_visits_30d
    counts = daily_visits_30_days.map { |day| day[:count] }
    counts.empty? ? 0 : (counts.sum.to_f / counts.size).round(1)
  end

  def peak_daily_visits_30d
    daily_visits_30_days.map { |day| day[:count] }.max || 0
  end

  def daily_visits_30_days
    padded_daily_counts(@scope.last_30_days, (Date.today - 29)..Date.today)
  end

  private

  def last_7_range
    (Date.today - 6)..Date.today
  end

  def last_30_range
    (Date.today - 29)..Date.today
  end

  def padded_daily_counts(scope, range)
    raw_counts = scope.group(:viewed_on).count
    range.map do |date|
      { date: date, count: raw_counts[date] || 0 }
    end.reverse
  end
end