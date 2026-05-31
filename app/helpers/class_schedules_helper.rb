module ClassSchedulesHelper
  def local_class_time(schedule, format: :datetime, class_name: nil, prefix: nil)
    tag.time(
      server_formatted_class_time(schedule, format),
      datetime: schedule.starts_at.iso8601,
      class: class_name,
      data: {
        controller: "local-time",
        local_time_start_value: schedule.starts_at.iso8601,
        local_time_end_value: schedule.ends_at.iso8601,
        local_time_format_value: format.to_s,
        local_time_prefix_value: prefix.to_s
      }
    )
  end

  def class_schedule_time_field_value(schedule, attribute)
    value = schedule.public_send(attribute)
    return if value.blank?

    value.in_time_zone(schedule.time_zone || Time.zone).strftime("%Y-%m-%dT%H:%M")
  end

  def formatted_class_date_range(schedule)
    starts_at = schedule.starts_at.in_time_zone(schedule.time_zone || Time.zone)
    ends_at = schedule.ends_at.in_time_zone(schedule.time_zone || Time.zone)

    start_day = starts_at.day
    end_day = ends_at.day
    start_month = starts_at.strftime("%B")
    end_month = ends_at.strftime("%B")
    year = starts_at.year
    start_time = starts_at.strftime("%-l:%M %p")
    end_time = ends_at.strftime("%-l:%M %p")

    if starts_at.to_date == ends_at.to_date
      # Same day
      "#{start_day} #{start_month} #{year} #{start_time} - #{end_time}"
    elsif starts_at.month == ends_at.month && starts_at.year == ends_at.year
      # Same month, different days
      "#{start_day} - #{end_day} #{start_month} #{year} #{start_time} - #{end_time}"
    else
      # Different months
      "#{start_day} #{start_month} - #{end_day} #{end_month} #{year} #{start_time} - #{end_time}"
    end
  end

  private

  def server_formatted_class_time(schedule, format)
    case format.to_sym
    when :range
      "#{formatted_class_date_range(schedule)} #{schedule.time_zone&.tzinfo&.name}"
    else
      schedule.starts_at.in_time_zone(schedule.time_zone || Time.zone).to_fs(:long)
    end
  end
end
