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
    currency_for_country(country_resolver.normalized_country_code) || DEFAULT_CURRENCY
  end

  private

  attr_reader :request

  def country_resolver
    @country_resolver ||= CountryResolver.new(request)
  end

  def currency_for_country(country)
    return if country.blank?

    return "EUR" if EURO_COUNTRIES.include?(country)

    COUNTRY_CURRENCIES[country]
  end
end