module MeetupsHelper
  def meetup_time_field_value(meetup, attribute)
    value = meetup.public_send(attribute)
    return if value.blank?

    value.in_time_zone(meetup.time_zone || Time.zone).strftime("%Y-%m-%dT%H:%M")
  end

  def meetup_date_part(meetup)
    meetup.starts_at.in_time_zone(meetup.time_zone || Time.zone).strftime("%-d %b %Y")
  end

  def meetup_display_name(meetup)
    "#{meetup_date_part(meetup)}, #{meetup_time_part(meetup)}"
  end

  def meetup_online_pill(meetup)
    return unless meetup.online?

    tag.span(
      class: "inline-flex items-center gap-1.5 rounded-full bg-indigo-50 px-2.5 py-0.5 text-xs font-bold text-indigo-700 ring-1 ring-inset ring-indigo-700/10 shadow-sm"
    ) do
      safe_join([
        tag.span(class: "h-1.5 w-1.5 rounded-full bg-indigo-500 animate-pulse", aria: { hidden: true }),
        "Live Online"
      ])
    end
  end

  def meetup_time_part(meetup)
    starts_at = meetup.starts_at.in_time_zone(meetup.time_zone || Time.zone)
    ends_at = meetup.ends_at.in_time_zone(meetup.time_zone || Time.zone)
    tz_abbr = starts_at.strftime("%Z")

    "#{starts_at.strftime('%-l:%M %p')} – #{ends_at.strftime('%-l:%M %p')} #{tz_abbr}"
  end
end