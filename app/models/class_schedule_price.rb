class ClassSchedulePrice < ApplicationRecord
  belongs_to :class_schedule

  before_validation :normalize_currency

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
  validates :currency, length: { is: 3 }
  validates :currency, uniqueness: { scope: :class_schedule_id }

  def display_amount
    "#{currency.upcase} #{format('%.2f', amount.to_f)}"
  end

  private

  def normalize_currency
    self.currency = currency.to_s.upcase.strip
  end
end
