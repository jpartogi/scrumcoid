class CountryResolver
  NAMES_BY_CODE = {
    "AU" => "Australia",
    "CA" => "Canada",
    "DE" => "Germany",
    "FR" => "France",
    "GB" => "United Kingdom",
    "ID" => "Indonesia",
    "IN" => "India",
    "JP" => "Japan",
    "MY" => "Malaysia",
    "NL" => "Netherlands",
    "NZ" => "New Zealand",
    "PH" => "Philippines",
    "SG" => "Singapore",
    "TH" => "Thailand",
    "US" => "United States",
    "VN" => "Vietnam"
  }.freeze

  UNKNOWN = "Unknown"

  def initialize(request)
    @request = request
  end

  def country_code
    @country_code ||= [
      request.headers["CF-IPCountry"],
      request.headers["X-Country-Code"],
      request.headers["X-AppEngine-Country"],
      request_location_country_code
    ].compact_blank.first.to_s.upcase.presence
  end

  def normalized_country_code
    code = country_code
    return nil if code.blank? || code == "XX"

    code
  end

  def display_name(code = normalized_country_code)
    return UNKNOWN if code.blank?

    NAMES_BY_CODE[code] || code
  end

  def self.display_name_for(code)
    new(Struct.new(:headers).new({})).display_name(code)
  end

  private

  attr_reader :request

  def request_location_country_code
    request.location&.country_code if request.respond_to?(:location)
  rescue StandardError
    nil
  end
end