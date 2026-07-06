module ApplicationHelper
  def country_flag_emoji(country_code)
    return "" if country_code.blank?

    code = country_code.to_s.upcase.strip
    return "" unless code.match?(/\A[A-Z]{2}\z/)

    code.codepoints.map { |c| c + 127397 }.pack("U*")
  end
end
