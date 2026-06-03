require "test_helper"

class UniqueVisitTest < ActiveSupport::TestCase
  test "validations" do
    visit = UniqueVisit.new
    assert_not visit.valid?
    assert_includes visit.errors[:fingerprint], "can't be blank"
    assert_includes visit.errors[:visited_on], "can't be blank"

    # valid visit
    visit.fingerprint = "somehash"
    visit.visited_on = Date.today
    assert visit.valid?
    assert visit.save

    # DB unique index (not AR validates) prevents duplicate (fingerprint, visited_on).
    # We rely on the index + create_or_find_by! (which catches RecordNotUnique).
    duplicate = UniqueVisit.new(fingerprint: "somehash", visited_on: Date.today)
    assert duplicate.valid? # no model uniqueness validator (intentionally removed)
    assert_raises(ActiveRecord::RecordNotUnique) do
      duplicate.save!
    end
  end

  test "scopes" do
    # clean table for exact scope testing
    UniqueVisit.destroy_all

    today_visit = UniqueVisit.create!(fingerprint: "ip1", visited_on: Date.today)
    yesterday_visit = UniqueVisit.create!(fingerprint: "ip2", visited_on: Date.yesterday)
    six_days_ago = UniqueVisit.create!(fingerprint: "ip6", visited_on: (Date.today - 6))
    seven_days_ago = UniqueVisit.create!(fingerprint: "ip7", visited_on: (Date.today - 7))
    old_visit = UniqueVisit.create!(fingerprint: "ip3", visited_on: 10.days.ago.to_date)

    assert_equal [today_visit], UniqueVisit.today
    assert_equal [yesterday_visit], UniqueVisit.yesterday
    
    assert_includes UniqueVisit.last_7_days, today_visit
    assert_includes UniqueVisit.last_7_days, yesterday_visit
    assert_includes UniqueVisit.last_7_days, six_days_ago
    assert_not_includes UniqueVisit.last_7_days, seven_days_ago
    assert_not_includes UniqueVisit.last_7_days, old_visit
  end

  test "prune_old! and distinct_count_in_range" do
    UniqueVisit.destroy_all

    UniqueVisit.create!(fingerprint: "a", visited_on: Date.today)
    UniqueVisit.create!(fingerprint: "b", visited_on: Date.today - 10)
    UniqueVisit.create!(fingerprint: "c", visited_on: Date.today - 100)

    assert_equal 2, UniqueVisit.distinct_count_in_range((Date.today - 29)..Date.today)
    assert_equal 3, UniqueVisit.distinct_count_in_range((Date.today - 200)..Date.today)

    deleted = UniqueVisit.prune_old!(retention_days: 30)
    assert_equal 1, deleted
    assert_equal 2, UniqueVisit.count
  end
end
