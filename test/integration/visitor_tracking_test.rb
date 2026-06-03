require "test_helper"

class VisitorTrackingTest < ActionDispatch::IntegrationTest
  test "visitor-facing visits are tracked uniquely by cookie visitor ID (preferred over IP)" do
    UniqueVisit.destroy_all

    # 1. First visit: generates a visitor_id cookie (uuid), records a fingerprint
    assert_difference -> { UniqueVisit.count }, 1 do
      get root_path, headers: { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36" }
    end

    # Cookie should be set on the response (signed, permanent)
    set_cookie = response.headers["Set-Cookie"].to_s
    assert_match(/visitor_id/, set_cookie, "Should set a visitor_id cookie on first visit")

    first_visit = UniqueVisit.last
    refute_nil first_visit.fingerprint
    assert_equal Date.today, first_visit.visited_on

    # 2. Subsequent page from same browser/session reuses the cookie visitor ID -> same fingerprint, no new record
    #    (the integration test client persists cookies from previous responses)
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

    # Still the same fingerprint
    assert_equal first_visit.fingerprint, UniqueVisit.last.fingerprint
  end

  test "different visitors (separate cookie IDs) are tracked separately even from same IP" do
    UniqueVisit.destroy_all

    v1_fp = nil
    v2_fp = nil

    real_ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

    # Visitor A in its own isolated session (own cookie jar -> its own generated visitor_id)
    open_session do |sess|
      sess.get root_path, headers: { "User-Agent" => real_ua }
      assert_equal 1, UniqueVisit.count
      v1_fp = UniqueVisit.last.fingerprint
    end

    # Visitor B in a completely separate session (different cookie jar -> fresh generated visitor_id)
    open_session do |sess|
      sess.get courses_path, headers: { "User-Agent" => real_ua }
      assert_equal 2, UniqueVisit.count
      v2_fp = UniqueVisit.last.fingerprint
    end

    assert_not_equal v1_fp, v2_fp
  end

  test "bot user agents and empty UA are not tracked as visits" do
    UniqueVisit.destroy_all

    bot_uas = [
      "Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)",
      "Mozilla/5.0 (compatible; bingbot/2.0; +http://www.bing.com/bingbot.htm)",
      "curl/7.68.0",
      "" # empty
    ]

    bot_uas.each do |ua|
      assert_no_difference -> { UniqueVisit.count }, "Bot UA should not create a visit: #{ua.inspect}" do
        get root_path, headers: { "User-Agent" => ua }
      end
    end

    # Real browser UA should track
    assert_difference -> { UniqueVisit.count }, 1 do
      get root_path, headers: { "User-Agent" => "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" }
    end
  end

  test "same visitor on a different calendar day creates a new unique visit record (new day bucket)" do
    UniqueVisit.destroy_all

    real_ua = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

    # Use travel + open_session with good UA. Verify different day buckets get separate records.
    travel_to(Date.today - 1) do
      open_session do |sess|
        sess.get root_path, headers: { "User-Agent" => real_ua }
      end
    end

    # After the past-day visit, we should have at least one record for yesterday
    assert_operator UniqueVisit.where(visited_on: Date.today - 1).count, :>=, 1

    # A visit today creates a record for the current day bucket
    assert_difference -> { UniqueVisit.count }, 1 do
      get courses_path, headers: { "User-Agent" => real_ua }
    end
    assert_operator UniqueVisit.where(visited_on: Date.today).count, :>=, 1

    # Distinct days are represented
    days = UniqueVisit.pluck(:visited_on).uniq.sort
    assert_includes days, Date.today - 1
    assert_includes days, Date.today
  end

  test "admin-facing pages are not tracked" do
    UniqueVisit.destroy_all
    sign_in users(:admin)

    assert_no_difference -> { UniqueVisit.count } do
      get admin_root_path
    end
  end

  test "admin dashboard computes 7/30-day padded stats and more visitor metrics" do
    UniqueVisit.destroy_all
    sign_in users(:admin)

    # Seed some data (use fingerprint now)
    UniqueVisit.create!(fingerprint: "h1", visited_on: Date.today)
    UniqueVisit.create!(fingerprint: "h2", visited_on: Date.today)
    UniqueVisit.create!(fingerprint: "h3", visited_on: Date.yesterday)
    UniqueVisit.create!(fingerprint: "h4", visited_on: Date.today - 6)
    UniqueVisit.create!(fingerprint: "h5", visited_on: Date.today - 20)

    get admin_root_path

    assert_response :success

    # 7 daily rows in the detailed list
    assert_select "div", text: /Daily unique visits/i
    assert_select ".divide-y .flex.items-center.justify-between", count: 7

    # New more-stats elements from 30-day snapshot
    assert_select "div", text: /30-day snapshot/i
    assert_select "div", text: /Avg \/ day/i
    assert_select "div", text: /Peak day/i
    assert_select "p", text: "Today's Visitors"

    # The new unique visitor cards
    assert_select "p", text: "Unique Visitors (7d)"
    assert_select "p", text: "Unique Visitors (30d)"
  end
end
