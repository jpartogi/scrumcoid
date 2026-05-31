require "test_helper"

class VisitorTrackingTest < ActionDispatch::IntegrationTest
  test "visitor-facing visits are tracked uniquely by IP per day" do
    UniqueVisit.destroy_all

    # 1. Visit visitor-facing home page
    assert_difference -> { UniqueVisit.count }, 1 do
      get root_path
    end

    # 2. Visit another visitor-facing page from same IP (should not increment count)
    assert_no_difference -> { UniqueVisit.count } do
      get courses_path
    end

    # 3. Verify hashing IP is used and today's date is assigned
    visit = UniqueVisit.last
    expected_hash = Digest::SHA256.hexdigest("127.0.0.1")
    assert_equal expected_hash, visit.ip_hash
    assert_equal Date.today, visit.visited_on
  end

  test "admin-facing pages are not tracked" do
    UniqueVisit.destroy_all
    sign_in users(:admin)

    assert_no_difference -> { UniqueVisit.count } do
      get admin_root_path
    end
  end
end
