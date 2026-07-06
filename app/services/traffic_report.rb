class TrafficReport
  PERIODS = [7, 30, 90].freeze
  DEFAULT_PERIOD = 30

  PageRow = Data.define(:path, :label, :unique_views)
  CountryRow = Data.define(:country_code, :country_name, :unique_visitors)
  ReferrerRow = Data.define(:category, :label, :unique_visitors)

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

  def reporting_today
    UniqueVisit.reporting_today
  end

  def daily_visits
    @daily_visits ||= UniqueVisit.daily_counts(@days)
  end

  def avg_daily_visits
    counts = daily_visits.map { |day| day[:count] }
    counts.empty? ? 0 : (counts.sum.to_f / counts.size).round(1)
  end

  def peak_daily_visits
    daily_visits.map { |day| day[:count] }.max || 0
  end

  def total_retained_visitors
    UniqueVisit.distinct.count(:fingerprint)
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

  def top_referrers
    visits = UniqueVisit.in_reporting_period(@days).select(:fingerprint, :referrer)
    
    fingerprint_to_referrer = {}
    visits.each do |visit|
      fp = visit.fingerprint
      ref = visit.referrer
      if !fingerprint_to_referrer.key?(fp) || (fingerprint_to_referrer[fp].blank? && ref.present?)
        fingerprint_to_referrer[fp] = ref
      end
    end
    
    category_counts = Hash.new(0)
    fingerprint_to_referrer.each_value do |referrer|
      category = classify_referrer(referrer)
      category_counts[category] += 1
    end
    
    sorted_categories = category_counts.sort_by { |_, count| -count }
    
    sorted_categories.map do |category, count|
      ReferrerRow.new(
        category: category,
        label: referrer_label_for(category),
        unique_visitors: count
      )
    end
  end

  private

  def classify_referrer(referrer)
    return :direct if referrer.blank?
    
    begin
      uri = URI.parse(referrer)
      host = uri.host.to_s.downcase
      
      # Remove 'www.' prefix if present
      host = host.delete_prefix("www.")
      
      return :direct if host.blank? || host == "scrum.co.id" || host.include?("localhost") || host.include?("127.0.0.1")
      
      if host.include?("google.")
        :google
      elsif host.include?("scrum.org")
        :scrum_org
      elsif host.include?("facebook.com") || host.include?("instagram.com") || 
            host.include?("linkedin.com") || host.include?("twitter.com") || 
            host == "t.co" || host.include?("tiktok.com") || 
            host.include?("youtube.com") || host.include?("reddit.com")
        :social_media
      elsif host.include?("bing.com") || host.include?("yahoo.com") || 
            host.include?("duckduckgo.com") || host.include?("yandex.") || 
            host.include?("baidu.com")
        :search_engines
      else
        host
      end
    rescue URI::InvalidURIError
      :other
    end
  end

  def referrer_label_for(category)
    case category
    when :direct then "Direct / Unknown"
    when :google then "Google Search"
    when :scrum_org then "Scrum.org"
    when :social_media then "Social Media"
    when :search_engines then "Other Search Engines"
    when :other then "Other / Invalid"
    else
      category
    end
  end
end