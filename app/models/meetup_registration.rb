class MeetupRegistration < ApplicationRecord
  enum :status, { active: 0, cancelled: 1 }

  belongs_to :meetup

  validates :visitor_name, :visitor_email, presence: true
  validates :visitor_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :visitor_email, uniqueness: { scope: :meetup_id, case_sensitive: false }
  validate :meetup_accepts_registration, on: :create

  scope :pending_follow_up, -> {
    active.where(follow_up_email_sent_at: nil).joins(:meetup).merge(Meetup.where("meetups.ends_at < ?", Time.current))
  }

  def send_confirmation_email!
    MeetupMailer.confirmation(self).deliver_later
    update!(confirmation_email_sent_at: Time.current)
  end

  def send_follow_up_email!
    return if follow_up_email_sent_at.present?
    return if meetup.donation_url.blank?

    MeetupMailer.follow_up(self).deliver_later
    update!(follow_up_email_sent_at: Time.current)
  end

  private

  def meetup_accepts_registration
    return if meetup.blank?

    if meetup.full?
      errors.add(:meetup, "is full")
    elsif meetup.registration_closed?
      errors.add(:meetup, "is closed for registration")
    end
  end
end