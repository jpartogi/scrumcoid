class MeetupsController < ApplicationController
  def index
    @meetups = Meetup.published.upcoming
  end

  def show
    @meetup = Meetup.published.find_by!(slug: params[:id])
    @registration = @meetup.meetup_registrations.find_by(
      visitor_email: session[:meetup_registration_email],
      status: :active
    )
    track_page_view(@meetup)
  end
end