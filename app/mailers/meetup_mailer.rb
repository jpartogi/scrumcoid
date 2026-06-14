class MeetupMailer < ApplicationMailer
  helper MeetupsHelper
  def confirmation(registration)
    @registration = registration
    @meetup = registration.meetup

    mail(
      to: registration.visitor_email,
      subject: "Konfirmasi pendaftaran meetup #{@meetup.slug}"
    )
  end

  def follow_up(registration)
    @registration = registration
    @meetup = registration.meetup
    @donation_url = @meetup.donation_url

    mail(
      to: registration.visitor_email,
      subject: "Terima kasih telah hadir di meetup #{@meetup.slug}"
    )
  end
end