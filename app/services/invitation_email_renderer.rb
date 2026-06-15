class InvitationEmailRenderer
  include ClassSchedulesHelper
  include Rails.application.routes.url_helpers

  def self.render(enrollment, format: :text)
    new(enrollment).render(format: format)
  end

  def initialize(enrollment)
    @enrollment = enrollment
    @class_schedule = enrollment.class_schedule
    @course = @class_schedule.course
  end

  def render(format: :text)
    template = template_for(format)
    substitute(template, html: format == :html)
  end

  private

  def template_for(format)
    rich_text = @course.invitation_email
    return "" if rich_text.blank?

    if format == :html
      rich_text.body.to_html
    else
      rich_text.body.to_plain_text
    end
  end

  def substitute(template, html:)
    substitutions.each do |key, value|
      replacement = html ? ERB::Util.html_escape(value.to_s) : value.to_s
      template = template.gsub("{{#{key}}}", replacement)
    end
    template
  end

  def substitutions
    {
      "first_name" => participant_first_name,
      "last_name" => participant_last_name,
      "full_name" => @enrollment.attendee_name,
      "email" => @enrollment.attendee_email,
      "course_title" => @course.title,
      "class_date" => class_schedule_date_part(@class_schedule),
      "class_time" => class_schedule_time_part(@class_schedule),
      "class_location" => @class_schedule.online? ? "Live online" : @class_schedule.location,
      "venue_name" => @class_schedule.venue_name.to_s,
      "venue_address" => @class_schedule.venue_address.to_s,
      "class_schedule_url" => class_schedule_public_url
    }
  end

  def participant_first_name
    @enrollment.first_name.presence || @enrollment.user&.name.to_s.split(/\s+/, 2).first.to_s
  end

  def participant_last_name
    @enrollment.last_name.presence || @enrollment.user&.name.to_s.split(/\s+/, 2).last.to_s
  end

  def class_schedule_public_url
    url_for(
      controller: "/class_schedules",
      action: "show",
      course_slug: @course.slug,
      id: @class_schedule.id,
      **default_url_options
    )
  end

  def default_url_options
    Rails.application.config.action_mailer.default_url_options || { host: "www.scrum.co.id" }
  end
end