class Meetups::RegistrationsController < ApplicationController
  before_action :set_meetup

  def new
    @registration = @meetup.meetup_registrations.build
  end

  def create
    @registration = @meetup.meetup_registrations.build(registration_params)

    if @registration.save
      @registration.send_confirmation_email!
      session[:meetup_registration_email] = @registration.visitor_email.strip.downcase

      redirect_to meetup_path(@meetup),
                  notice: "Terima kasih! Kami telah mengirim email konfirmasi beserta tautan untuk bergabung ke #{@registration.visitor_email}."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_meetup
    @meetup = Meetup.published.find_by!(slug: params[:meetup_id])
  end

  def registration_params
    params.require(:meetup_registration).permit(:visitor_name, :visitor_email)
  end
end