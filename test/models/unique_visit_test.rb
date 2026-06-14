require "test_helper"

class UniqueVisitTest < ActiveSupport::TestCase
  setup do
    UniqueVisit.destroy_all
  end

  test "requires fingerprint and visited_at" do
    visit = UniqueVisit.new
    assert_not visit.valid?
    assert_includes visit.errors[:fingerprint], "can't be blank"
    assert_includes visit.errors[:visited_at], "can't be blank"
  end

  test "defaults timezone to Australia/Brisbane" do
    visit = UniqueVisit.new(fingerprint: "visitor-1", visited_at: Time.current)
    assert_equal "Australia/Brisbane", visit.timezone
  end

  test "track! stores UTC timestamp and reporting timezone" do
    brisbane = Time.find_zone("Australia/Brisbane")
    travel_to brisbane.local(2026, 6, 14, 9, 30, 0) do
      visit = UniqueVisit.track!(fingerprint: "visitor-1")

      assert_equal "visitor-1", visit.fingerprint
      assert_equal "Australia/Brisbane", visit.timezone
      assert_equal Time.current, visit.visited_at
      assert visit.visited_at.utc?
    end
  end

  test "track! deduplicates visits within the same Brisbane calendar day" do
    brisbane = Time.find_zone("Australia/Brisbane")

    travel_to brisbane.local(2026, 6, 14, 9, 0, 0) do
      first = UniqueVisit.track!(fingerprint: "visitor-1")
      second = UniqueVisit.track!(fingerprint: "visitor-1")

      assert_equal first.id, second.id
      assert_equal 1, UniqueVisit.count
    end

    travel_to brisbane.local(2026, 6, 14, 22, 0, 0) do
      third = UniqueVisit.track!(fingerprint: "visitor-1")
      assert_equal 1, UniqueVisit.count
      refute_nil third
    end
  end

  test "track! creates a new record on the next Brisbane calendar day" do
    brisbane = Time.find_zone("Australia/Brisbane")

    travel_to brisbane.local(2026, 6, 13, 23, 30, 0) do
      UniqueVisit.track!(fingerprint: "visitor-1")
    end

    travel_to brisbane.local(2026, 6, 14, 0, 30, 0) do
      assert_difference -> { UniqueVisit.count }, 1 do
        UniqueVisit.track!(fingerprint: "visitor-1")
      end
    end
  end

  test "late UTC evening still counts toward the next Brisbane day" do
    # 2026-06-14 22:00 UTC = 2026-06-15 08:00 Brisbane
    travel_to Time.utc(2026, 6, 14, 22, 0, 0) do
      visit = UniqueVisit.track!(fingerprint: "visitor-utc")
      assert_equal Date.new(2026, 6, 15), UniqueVisit.reporting_date_for(visit.visited_at, visit.timezone)
      assert_equal 1, UniqueVisit.on_reporting_date(Date.new(2026, 6, 15)).count
      assert_equal 0, UniqueVisit.on_reporting_date(Date.new(2026, 6, 14)).count
    end
  end

  test "daily_counts groups visits by Brisbane calendar day" do
    brisbane = Time.find_zone("Australia/Brisbane")

    travel_to brisbane.local(2026, 6, 14, 10, 0, 0) do
      UniqueVisit.track!(fingerprint: "a")
      UniqueVisit.track!(fingerprint: "b")
    end

    travel_to brisbane.local(2026, 6, 13, 10, 0, 0) do
      UniqueVisit.track!(fingerprint: "c")
    end

    travel_to brisbane.local(2026, 6, 14, 12, 0, 0) do
      counts = UniqueVisit.daily_counts(7)
      today_entry = counts.find { |day| day[:date] == Date.new(2026, 6, 14) }
      yesterday_entry = counts.find { |day| day[:date] == Date.new(2026, 6, 13) }

      assert_equal 2, today_entry[:count]
      assert_equal 1, yesterday_entry[:count]
      assert_equal 7, counts.size
    end
  end

  test "distinct_visitors_in_days counts unique fingerprints across Brisbane days" do
    brisbane = Time.find_zone("Australia/Brisbane")

    travel_to brisbane.local(2026, 6, 14, 10, 0, 0) do
      UniqueVisit.track!(fingerprint: "a")
      UniqueVisit.track!(fingerprint: "b")
    end

    travel_to brisbane.local(2026, 6, 13, 10, 0, 0) do
      UniqueVisit.track!(fingerprint: "a")
    end

    travel_to brisbane.local(2026, 6, 14, 12, 0, 0) do
      assert_equal 2, UniqueVisit.distinct_visitors_in_days(7)
    end
  end

  test "prune_old! removes visits before the Brisbane retention window" do
    brisbane = Time.find_zone("Australia/Brisbane")

    travel_to brisbane.local(2026, 6, 14, 10, 0, 0) do
      UniqueVisit.track!(fingerprint: "recent")
    end

    travel_to brisbane.local(2026, 3, 1, 10, 0, 0) do
      UniqueVisit.track!(fingerprint: "old")
    end

    travel_to brisbane.local(2026, 6, 14, 12, 0, 0) do
      deleted = UniqueVisit.prune_old!(retention_days: 30)
      assert_equal 1, deleted
      assert_equal 1, UniqueVisit.count
      assert_equal "recent", UniqueVisit.first.fingerprint
    end
  end
end