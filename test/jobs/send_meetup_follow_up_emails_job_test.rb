require "test_helper"

class SendMeetupFollowUpEmailsJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper

  test "sends follow up emails for ended meetups without follow up timestamp" do
    registration = meetup_registrations(:pending_follow_up)

    assert_enqueued_emails 1 do
      SendMeetupFollowUpEmailsJob.perform_now
    end

    assert_not_nil registration.reload.follow_up_email_sent_at
  end

  test "skips registrations that already received follow up" do
    registration = meetup_registrations(:pending_follow_up)
    registration.update!(follow_up_email_sent_at: 1.hour.ago)

    assert_no_enqueued_emails do
      SendMeetupFollowUpEmailsJob.perform_now
    end
  end
end