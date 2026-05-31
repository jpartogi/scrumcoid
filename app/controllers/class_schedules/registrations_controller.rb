class ClassSchedules::RegistrationsController < ApplicationController
  before_action :set_class_schedule

  def new
    @registration = Registration.new
    @registration.enrollments.build # start with one participant
  end

  def create
    @registration = Registration.new(registration_params)
    @registration.class_schedule = @class_schedule

    if @registration.save
      # Create participant enrollments
      # (already handled via nested attributes)

      # Send email
      RegistrationMailer.quotation(@registration).deliver_later

      # Update status
      @registration.update(status: :quotation_sent, quotation_sent_at: Time.current)

      redirect_to class_schedule_path(@class_schedule), 
                  notice: "Thank you! We have received your registration request. A quotation has been sent to #{@registration.finance_email}."
    else
      @registration.enrollments.build if @registration.enrollments.empty?
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_class_schedule
    @class_schedule = ClassSchedule.find(params[:class_schedule_id])
  end

  def registration_params
    params.require(:registration).permit(
      :finance_name, :finance_email, :company_name, :company_address, :company_phone,
      enrollments_attributes: [:id, :visitor_name, :visitor_email, :_destroy]
    )
  end
end
