require "test_helper"

class CountryResolverTest < ActiveSupport::TestCase
  Request = Struct.new(:headers) do
    def location
      nil
    end
  end

  test "resolves country code from cloudflare header" do
    request = Request.new({ "CF-IPCountry" => "id" })

    resolver = CountryResolver.new(request)

    assert_equal "ID", resolver.country_code
    assert_equal "ID", resolver.normalized_country_code
    assert_equal "Indonesia", resolver.display_name
  end

  test "treats unknown cloudflare country as nil" do
    request = Request.new({ "CF-IPCountry" => "XX" })

    resolver = CountryResolver.new(request)

    assert_equal "XX", resolver.country_code
    assert_nil resolver.normalized_country_code
    assert_equal CountryResolver::UNKNOWN, resolver.display_name
  end
end