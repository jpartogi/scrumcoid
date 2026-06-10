module ClassScheduleRouting
  extend ActiveSupport::Concern

  def class_schedule_path(schedule, options = {})
    if schedule.is_a?(ClassSchedule)
      url_for(
        controller: "class_schedules",
        action: "show",
        course_slug: schedule.course.slug,
        id: schedule.id,
        only_path: true,
        **options
      )
    else
      url_for(controller: "class_schedules", action: "show", only_path: true, **options, id: schedule)
    end
  end

  def class_schedule_url(schedule, options = {})
    if schedule.is_a?(ClassSchedule)
      url_for(
        controller: "class_schedules",
        action: "show",
        course_slug: schedule.course.slug,
        id: schedule.id,
        **options
      )
    else
      url_for(controller: "class_schedules", action: "show", **options, id: schedule)
    end
  end
end