class Registration < ApplicationRecord
  belongs_to :class_schedule
  has_many :enrollments, dependent: :destroy
  accepts_nested_attributes_for :enrollments, allow_destroy: true, reject_if: :all_blank

  enum :status, {
    pending_quotation: 0,
    quotation_sent: 1,
    confirmed: 2,
    cancelled: 3
  }

  validates :finance_name, :finance_email, :company_name, presence: true
  validates :finance_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  delegate :course, to: :class_schedule

  def participants
    enrollments
  end

  def total_participants
    enrollments.count
  end
end
