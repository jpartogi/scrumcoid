require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "country_flag_emoji returns correct unicode flag" do
    assert_equal "🇮🇩", country_flag_emoji("ID")
    assert_equal "🇸🇬", country_flag_emoji("sg")
    assert_equal "🇺🇸", country_flag_emoji("US")
  end

  test "country_flag_emoji returns empty string for invalid codes" do
    assert_equal "", country_flag_emoji(nil)
    assert_equal "", country_flag_emoji("")
    assert_equal "", country_flag_emoji("UNKNOWN")
    assert_equal "", country_flag_emoji("12")
    assert_equal "", country_flag_emoji("A")
  end
end
