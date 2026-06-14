class SendMeetupFollowUpEmailsJob < ApplicationJob
  queue_as :default

  def perform
    MeetupRegistration.pending_follow_up.includes(:meetup).find_each do |registration|
      next if registration.meetup.donation_url.blank?

      registration.send_follow_up_email!
    end
  end
end