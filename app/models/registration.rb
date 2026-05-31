class Registration < ApplicationRecord
  belongs_to :class_schedule
  belongs_to :customer, optional: true
  has_many :enrollments, dependent: :destroy
  accepts_nested_attributes_for :enrollments, allow_destroy: true, reject_if: :all_blank

  enum :status, {
    pending_quotation: 0,
    quotation_sent: 1,
    confirmed: 2,
    cancelled: 3
  }

  before_validation :assign_class_schedule_to_enrollments
  before_validation :sync_customer

  validates :finance_name, :finance_email, :company_name, presence: true
  validates :finance_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  delegate :course, to: :class_schedule

  def participants
    enrollments
  end

  def total_participants
    enrollments.count
  end

  private

  def assign_class_schedule_to_enrollments
    if class_schedule.present?
      enrollments.each do |enrollment|
        enrollment.class_schedule = class_schedule
      end
    end
  end

  def sync_customer
    return if finance_email.blank?

    cust = Customer.find_or_initialize_by(finance_email: finance_email.strip.downcase)
    cust.assign_attributes(
      finance_name: finance_name,
      company_name: company_name,
      company_phone: company_phone,
      company_address: company_address
    )
    if cust.save
      self.customer = cust
    else
      cust.errors.full_messages.each do |msg|
        errors.add(:base, "Customer error: #{msg}")
      end
    end
  end
end
