require "test_helper"

class TrafficPageViewTest < ActiveSupport::TestCase
  setup do
    TrafficPageView.destroy_all
  end

  test "track! stores normalized path and deduplicates per day" do
    brisbane = Time.find_zone("Australia/Brisbane")

    travel_to brisbane.local(2026, 6, 14, 10, 0, 0) do
      assert_difference -> { TrafficPageView.count }, 1 do
        TrafficPageView.track!(path: "courses", fingerprint: "visitor-1")
      end

      assert_no_difference -> { TrafficPageView.count } do
        TrafficPageView.track!(path: "/courses", fingerprint: "visitor-1")
      end

      assert_equal "/courses", TrafficPageView.last.path
    end
  end

  test "normalize_path handles root path" do
    assert_equal "/", TrafficPageView.normalize_path("")
    assert_equal "/", TrafficPageView.normalize_path("/")
  end
end