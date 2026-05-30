require "test_helper"

class ClassSchedulePriceTest < ActiveSupport::TestCase
  test "normalizes currency" do
    price = ClassSchedulePrice.new(class_schedule: class_schedules(:open_online), amount: 100, currency: " eur ")

    price.valid?

    assert_equal "EUR", price.currency
  end
end
