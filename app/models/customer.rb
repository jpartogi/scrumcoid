class Customer < ApplicationRecord
  has_many :registrations, dependent: :destroy
  has_many :enrollments, through: :registrations

  validates :finance_email, presence: true, uniqueness: { case_sensitive: false }
  validates :finance_email, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, message: "must be a valid email address" }
  validates :finance_name, :company_name, presence: true
end
