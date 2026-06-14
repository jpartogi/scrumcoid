require "test_helper"

class VisitorTrackingTest < ActionDispatch::IntegrationTest
  setup do
    UniqueVisit.destroy_all
  end

  test "visitor-facing visits are tracked uniquely by cookie visitor ID (preferred over IP)" do
    brisbane = Time.find_zone("Australia/Brisbane")
    travel_to brisbane.local(2026, 6, 14, 10, 0, 0) do
      assert_difference -> { UniqueVisit.count }, 1 do
        get root_path, headers: { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
      end

      set_cookie = response.headers["Set-Cookie"].to_s
      assert_match(/visitor_id/, set_cookie, "Should set a visitor_id cookie on first visit")

      first_visit = UniqueVisit.last
      refute_nil first_visit.fingerprint
      assert_equal "Australia/Brisbane", first_visit.timezone
      assert_equal Date.new(2026, 6, 14), UniqueVisit.reporting_date_for(first_visit.visited_at, first_visit.timezone)

      log_output = StringIO.new
      original_logger = Rails.logger
      Rails.logger = ActiveSupport::Logger.new(log_output)
      Rails.logger.level = Logger::ERROR

      assert_no_difference -> { UniqueVisit.count } do
        get courses_path, headers: { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
      end

      Rails.logger = original_logger
      assert_no_match(/Failed to track unique visit/i, log_output.string,
        "Repeat visits from same visitor (cookie) must not trigger error logging")

      assert_equal first_visit.fingerprint, UniqueVisit.last.fingerprint
    end
  end

  test "different visitors (separate cookie IDs) are tracked separately even from same IP" do
    brisbane = Time.find_zone("Australia/Brisbane")
    real_ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

    travel_to brisbane.local(2026, 6, 14, 10, 0, 0) do
      v1_fp = nil
      v2_fp = nil

      open_session do |sess|
        sess.get root_path, headers: { "User-Agent" => real_ua }
        assert_equal 1, UniqueVisit.count
        v1_fp = UniqueVisit.last.fingerprint
      end

      open_session do |sess|
        sess.get courses_path, headers: { "User-Agent" => real_ua }
        assert_equal 2, UniqueVisit.count
        v2_fp = UniqueVisit.last.fingerprint
      end

      assert_not_equal v1_fp, v2_fp
    end
  end

  test "bot user agents and empty UA are not tracked as visits" do
    brisbane = Time.find_zone("Australia/Brisbane")

    travel_to brisbane.local(2026, 6, 14, 10, 0, 0) do
      bot_uas = [
        "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)",
        "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)",
        "curl/7.68.0",
        ""
      ]

      bot_uas.each do |ua|
        assert_no_difference -> { UniqueVisit.count }, "Bot UA should not create a visit: #{ua.inspect}" do
          get root_path, headers: { "User-Agent" => ua }
        end
      end

      assert_difference -> { UniqueVisit.count }, 1 do
        get root_path, headers: { "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }
      end
    end
  end

  test "same visitor on a different Brisbane calendar day creates a new unique visit record" do
    brisbane = Time.find_zone("Australia/Brisbane")
    real_ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

    travel_to brisbane.local(2026, 6, 13, 10, 0, 0) do
      open_session do |sess|
        sess.get root_path, headers: { "User-Agent" => real_ua }
      end
    end

    assert_operator UniqueVisit.on_reporting_date(Date.new(2026, 6, 13)).count, :>=, 1

    travel_to brisbane.local(2026, 6, 14, 10, 0, 0) do
      assert_difference -> { UniqueVisit.count }, 1 do
        get courses_path, headers: { "User-Agent" => real_ua }
      end
    end

    assert_operator UniqueVisit.on_reporting_date(Date.new(2026, 6, 14)).count, :>=, 1

    days = UniqueVisit.pluck(:visited_at, :timezone).map { |visited_at, timezone| UniqueVisit.reporting_date_for(visited_at, timezone) }.uniq.sort
    assert_includes days, Date.new(2026, 6, 13)
    assert_includes days, Date.new(2026, 6, 14)
  end

  test "admin-facing pages are not tracked" do
    sign_in users(:admin)

    assert_no_difference -> { UniqueVisit.count } do
      get admin_root_path
    end
  end

  test "admin dashboard computes 7/30-day padded stats and more visitor metrics" do
    brisbane = Time.find_zone("Australia/Brisbane")
    sign_in users(:admin)

    travel_to brisbane.local(2026, 6, 14, 12, 0, 0) do
      create_visit!(fingerprint: "h1", reporting_date: Date.new(2026, 6, 14))
      create_visit!(fingerprint: "h2", reporting_date: Date.new(2026, 6, 14))
      create_visit!(fingerprint: "h3", reporting_date: Date.new(2026, 6, 13))
      create_visit!(fingerprint: "h4", reporting_date: Date.new(2026, 6, 8))
      create_visit!(fingerprint: "h5", reporting_date: Date.new(2026, 5, 25))

      get admin_root_path

      assert_response :success
      assert_select "div", text: /Daily unique visits/i
      assert_select ".divide-y .flex.items-center.justify-between", count: 7
      assert_select "div", text: /30-day snapshot/i
      assert_select "div", text: /Avg \/ day/i
      assert_select "div", text: /Peak day/i
      assert_select "p", text: "Today's Visitors"
      assert_select "p", text: "Unique Visitors (7d)"
      assert_select "p", text: "Unique Visitors (30d)"
      assert_select "p", text: /Australia\/Brisbane/
    end
  end

  private

  def create_visit!(fingerprint:, reporting_date:)
    visited_at = UniqueVisit.utc_range_for_reporting_date(reporting_date).first + 1.hour
    UniqueVisit.create!(
      fingerprint: fingerprint,
      visited_at: visited_at,
      timezone: UniqueVisit::REPORTING_TIMEZONE
    )
  end
end