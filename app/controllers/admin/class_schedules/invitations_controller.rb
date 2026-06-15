class Admin::ClassSchedules::InvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_admin!
  before_action :set_class_schedule

  def new
    @course = @class_schedule.course
    @enrollments = @class_schedule.enrollments.active.includes(:user).order(:created_at)
    @subject = "Undangan: #{@course.title} #{helpers.class_schedule_date_part(@class_schedule)}"
    @sample_body_html = sample_invitation_body(format: :html)
  end

  def create
    @course = @class_schedule.course

    if @course.invitation_email.blank?
      redirect_to new_admin_class_schedule_invitations_path(@class_schedule),
                  alert: "Invitation email template is not configured for this course."
      return
    end

    enrollments = @class_schedule.enrollments.active.where(id: selected_enrollment_ids)

    if enrollments.empty?
      redirect_to new_admin_class_schedule_invitations_path(@class_schedule),
                  alert: "Select at least one student to send the invitation email."
      return
    end

    subject = params[:subject].to_s.strip.presence || "Undangan: #{@course.title}"

    enrollments.find_each do |enrollment|
      InvitationMailer.class_invitation(enrollment, subject: subject).deliver_later
      enrollment.update!(invitation_sent_at: Time.current, invitation_opened_at: nil)
    end

    notice = if enrollments.size == 1
      "Invitation email queued for 1 student."
    else
      "Invitation emails queued for #{enrollments.size} students."
    end

    redirect_to admin_class_schedule_path(@class_schedule), notice: notice
  end

  private

  def set_class_schedule
    @class_schedule = ClassSchedule.find(params[:class_schedule_id])
  end

  def selected_enrollment_ids
    Array(params[:enrollment_ids]).reject(&:blank?).map(&:to_i)
  end

  def sample_invitation_body(format: :text)
    return if @course.invitation_email.blank?

    enrollment = @enrollments.first || @class_schedule.enrollments.build(
      first_name: "Jane",
      last_name: "Doe",
      email: "jane@example.com"
    )
    InvitationEmailRenderer.render(enrollment, format: format)
  end
end