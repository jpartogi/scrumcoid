class MeetupMailer < ApplicationMailer
  helper MeetupsHelper
  def confirmation(registration)
    @registration = registration
    @meetup = registration.meetup

    attachments["meetup-#{@meetup.slug}.ics"] = {
      mime_type: "text/calendar; method=PUBLISH",
      content: MeetupIcs.generate(registration)
    }

    mail(
      to: registration.visitor_email,
      subject: "Konfirmasi pendaftaran meetup #{@meetup.slug}"
    )
  end

  def follow_up(registration)
    @registration = registration
    @meetup = registration.meetup
    @donation_url = @meetup.donation_url
    @next_meetup = Meetup.published.upcoming.where.not(id: @meetup.id).first

    mail(
      to: registration.visitor_email,
      subject: "Terima kasih telah hadir di meetup #{@meetup.slug}"
    )
  end
end