require "test_helper"

class UniqueVisitTest < ActiveSupport::TestCase
  test "validations" do
    visit = UniqueVisit.new
    assert_not visit.valid?
    assert_includes visit.errors[:ip_hash], "can't be blank"
    assert_includes visit.errors[:visited_on], "can't be blank"

    # valid visit
    visit.ip_hash = "somehash"
    visit.visited_on = Date.today
    assert visit.valid?
    assert visit.save

    # duplicate same day/IP
    duplicate = UniqueVisit.new(ip_hash: "somehash", visited_on: Date.today)
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:ip_hash], "has already been taken"
  end

  test "scopes" do
    # clean table for exact scope testing
    UniqueVisit.destroy_all

    today_visit = UniqueVisit.create!(ip_hash: "ip1", visited_on: Date.today)
    yesterday_visit = UniqueVisit.create!(ip_hash: "ip2", visited_on: Date.yesterday)
    old_visit = UniqueVisit.create!(ip_hash: "ip3", visited_on: 10.days.ago.to_date)

    assert_equal [today_visit], UniqueVisit.today
    assert_equal [yesterday_visit], UniqueVisit.yesterday
    
    assert_includes UniqueVisit.last_7_days, today_visit
    assert_includes UniqueVisit.last_7_days, yesterday_visit
    assert_not_includes UniqueVisit.last_7_days, old_visit
  end
end
