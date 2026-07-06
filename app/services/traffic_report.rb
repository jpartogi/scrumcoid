class TrafficReport
  PERIODS = [7, 30, 90].freeze
  DEFAULT_PERIOD = 30

  PageRow = Data.define(:path, :label, :unique_views)
  CountryRow = Data.define(:country_code, :country_name, :unique_visitors)

  def initialize(days: DEFAULT_PERIOD)
    @days = PERIODS.include?(days.to_i) ? days.to_i : DEFAULT_PERIOD
    @labeler = TrafficPageLabeler.new
  end

  attr_reader :days

  def reporting_timezone
    UniqueVisit::REPORTING_TIMEZONE
  end

  def reporting_timezone_abbr
    UniqueVisit.reporting_zone.now.strftime("%Z")
  end

  def period_start_on
    UniqueVisit.reporting_today - (@days - 1)
  end

  def period_end_on
    UniqueVisit.reporting_today
  end

  def total_unique_visitors
    UniqueVisit.in_reporting_period(@days).distinct.count(:fingerprint)
  end

  def tracked_page_count
    TrafficPageView.in_reporting_period(@days).distinct.count(:path)
  end

  def top_pages(limit: 25)
    counts = TrafficPageView.in_reporting_period(@days)
      .group(:path)
      .order(Arel.sql("COUNT(DISTINCT fingerprint) DESC"))
      .limit(limit)
      .count("DISTINCT fingerprint")

    counts.map do |path, unique_views|
      PageRow.new(path: path, label: @labeler.label(path), unique_views: unique_views)
    end
  end

  def top_countries(limit: 25)
    counts = UniqueVisit.in_reporting_period(@days)
      .where.not(country: [nil, ""])
      .group(:country)
      .order(Arel.sql("COUNT(DISTINCT fingerprint) DESC"))
      .limit(limit)
      .count("DISTINCT fingerprint")

    counts.map do |country_code, unique_visitors|
      CountryRow.new(
        country_code: country_code,
        country_name: CountryResolver.display_name_for(country_code),
        unique_visitors: unique_visitors
      )
    end
  end

  def unknown_country_visitors
    UniqueVisit.in_reporting_period(@days)
      .where(country: [nil, ""])
      .distinct
      .count(:fingerprint)
  end
end