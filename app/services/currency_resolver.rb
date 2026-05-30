class CurrencyResolver
  DEFAULT_CURRENCY = "USD"

  COUNTRY_CURRENCIES = {
    "AU" => "AUD",
    "NZ" => "NZD",
    "US" => "USD",
    "CA" => "CAD",
    "GB" => "GBP",
    "SG" => "SGD",
    "ID" => "IDR"
  }.freeze

  EURO_COUNTRIES = %w[
    AT BE CY EE FI FR DE GR IE IT LV LT LU MT NL PT SK SI ES
  ].freeze

  def initialize(request)
    @request = request
  end

  def currency
    currency_for_country(country_code) || DEFAULT_CURRENCY
  end

  private

  attr_reader :request

  def country_code
    [
      request.headers["CF-IPCountry"],
      request.headers["X-Country-Code"],
      request.headers["X-AppEngine-Country"],
      request_location_country_code
    ].compact_blank.first.to_s.upcase
  end

  def request_location_country_code
    request.location&.country_code if request.respond_to?(:location)
  rescue StandardError
    nil
  end

  def currency_for_country(country)
    return if country.blank? || country == "XX"
    return "EUR" if EURO_COUNTRIES.include?(country)

    COUNTRY_CURRENCIES[country]
  end
end
