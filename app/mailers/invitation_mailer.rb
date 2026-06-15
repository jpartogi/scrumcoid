class InvitationMailer < ApplicationMailer
  include ClassSchedulesHelper

  def class_invitation(enrollment, subject: nil)
    @enrollment = enrollment
    @class_schedule = enrollment.class_schedule
    @course = @class_schedule.course
    @body_html = InvitationEmailRenderer.render(enrollment, format: :html)
    @body_text = InvitationEmailRenderer.render(enrollment, format: :text)

    default_subject = "Undangan: #{@course.title} #{class_schedule_date_part(@class_schedule)}"

    mail(
      to: enrollment.attendee_email,
      subject: subject.presence || default_subject
    )
  end
end