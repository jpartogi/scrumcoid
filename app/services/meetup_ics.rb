class MeetupIcs
  include Rails.application.routes.url_helpers

  def self.generate(registration)
    new(registration).generate
  end

  def initialize(registration)
    @registration = registration
    @meetup = registration.meetup
  end

  def generate
    properties = [
      "BEGIN:VCALENDAR",
      "VERSION:2.0",
      "PRODID:-//Scrum.co.id//Meetup//EN",
      "CALSCALE:GREGORIAN",
      "METHOD:PUBLISH",
      "BEGIN:VEVENT",
      "UID:#{uid}",
      "DTSTAMP:#{utc_timestamp(Time.current)}",
      "DTSTART;TZID=#{tzid}:#{local_timestamp(@meetup.starts_at)}",
      "DTEND;TZID=#{tzid}:#{local_timestamp(@meetup.ends_at)}",
      "SUMMARY:#{escape(summary)}",
      "DESCRIPTION:#{escape(description)}",
      "LOCATION:#{escape(location)}",
      "URL:#{escape(event_url)}",
      "ORGANIZER;CN=Scrum.co.id:MAILTO:#{organizer_email}",
      "STATUS:CONFIRMED",
      "SEQUENCE:0",
      "END:VEVENT",
      "END:VCALENDAR"
    ]

    properties.map { |line| fold_line(line) }.join("\r\n")
  end

  private

  def uid
    "meetup-#{@meetup.id}-registration-#{@registration.id}@scrum.co.id"
  end

  def tzid
    @meetup.timezone
  end

  def summary
    "Scrum.co.id Meetup #{@meetup.slug}"
  end

  def description
    parts = [
      @meetup.excerpt,
      "Terdaftar atas nama: #{@registration.visitor_name}",
      (@meetup.join_link.present? ? "Tautan bergabung: #{@meetup.join_link}" : nil),
      "Detail meetup: #{event_url}"
    ]
    parts.compact.join("\n")
  end

  def location
    @meetup.join_link.presence || "Online — Scrum.co.id"
  end

  def event_url
    meetup_url(@meetup, default_url_options)
  end

  def organizer_email
    mail_from = ENV.fetch("MAILER_FROM", "noreply@scrum.co.id")
    mail_from.match(/<([^>]+)>/)&.[](1) || mail_from
  end

  def default_url_options
    {
      host: ENV.fetch("APP_HOST", "scrum.co.id"),
      protocol: Rails.env.local? ? "http" : "https"
    }
  end

  def local_timestamp(time)
    time.in_time_zone(@meetup.time_zone).strftime("%Y%m%dT%H%M%S")
  end

  def utc_timestamp(time)
    time.utc.strftime("%Y%m%dT%H%M%SZ")
  end

  def escape(value)
    value.to_s
      .gsub("\\", "\\\\")
      .gsub(";", "\\;")
      .gsub(",", "\\,")
      .gsub("\r\n", "\\n")
      .gsub("\n", "\\n")
  end

  def fold_line(line)
    return line if line.length <= 75

    folded = +""
    remaining = line
    while remaining.length > 75
      folded << remaining[0, 75] << "\r\n "
      remaining = remaining[75..]
    end
    folded << remaining
  end
end