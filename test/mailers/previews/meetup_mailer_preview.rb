class MeetupMailerPreview < ActionMailer::Preview
  def confirmation
    MeetupMailer.confirmation(MeetupRegistration.first)
  end

  def follow_up
    MeetupMailer.follow_up(MeetupRegistration.first)
  end
end