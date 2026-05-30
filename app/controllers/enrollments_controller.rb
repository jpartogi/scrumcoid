class EnrollmentsController < ApplicationController
  before_action :authenticate_user!, only: [ :destroy ]
  before_action :set_class_schedule

  def create
    unless @class_schedule.available_for_registration?
      redirect_to class_schedule_path(@class_schedule), alert: "This class is closed for registration."
      return
    end

    checkout_session = StripeCheckoutSession.create(
      class_schedule: @class_schedule,
      currency: current_currency,
      success_url: class_schedule_url(@class_schedule, checkout: "success"),
      cancel_url: class_schedule_url(@class_schedule, checkout: "cancelled")
    )

    redirect_to checkout_session.url, allow_other_host: true, status: :see_other
  rescue StripeCheckoutSession::ConfigurationError, StripeCheckoutSession::CheckoutError => error
    redirect_to class_schedule_path(@class_schedule), alert: error.message
  end

  def destroy
    enrollment = current_user.enrollments.find_by!(class_schedule: @class_schedule)
    enrollment.cancelled!
    redirect_to dashboard_path, notice: "Your registration was cancelled."
  end

  private

  def set_class_schedule
    @class_schedule = ClassSchedule.includes(course: :course_prices).find(params[:class_schedule_id])
  end
end
