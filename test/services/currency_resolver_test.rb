require "test_helper"

class CurrencyResolverTest < ActiveSupport::TestCase
  Request = Struct.new(:headers) do
    def location
      nil
    end
  end

  test "resolves currency from country header" do
    request = Request.new({ "CF-IPCountry" => "US" })

    assert_equal "USD", CurrencyResolver.new(request).currency
  end

  test "defaults to usd when country is unsupported" do
    request = Request.new({ "CF-IPCountry" => "JP" })

    assert_equal "USD", CurrencyResolver.new(request).currency
  end
end
