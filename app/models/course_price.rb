class CoursePrice < ApplicationRecord
  belongs_to :course

  before_validation :normalize_currency

  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :currency, presence: true
  validates :currency, length: { is: 3 }
  validates :currency, uniqueness: { scope: :course_id }

  def amount
    if has_attribute?(:amount)
      self[:amount]
    elsif has_attribute?(:amount_cents)
      self[:amount_cents].to_i / 100.0
    end
  end

  def amount=(value)
    if has_attribute?(:amount)
      self[:amount] = value
    elsif has_attribute?(:amount_cents)
      self[:amount_cents] = (value.to_f * 100).round
    end
  end

  def display_amount
    curr = currency.upcase
    if curr == "IDR"
      # Indonesian convention: no decimal places, comma-dash suffix
      formatted = ActiveSupport::NumberHelper.number_to_delimited(amount.to_i, delimiter: ".")
      "#{curr} #{formatted},-"
    else
      # Strip trailing .00 for clean display; keep decimals if non-zero
      num = amount.to_f
      formatted = num == num.floor ? ActiveSupport::NumberHelper.number_to_delimited(num.to_i) : ActiveSupport::NumberHelper.number_to_delimited(format('%.2f', num))
      "#{curr} #{formatted}"
    end
  end

  private

  def normalize_currency
    self.currency = currency.to_s.upcase.strip
  end
end
