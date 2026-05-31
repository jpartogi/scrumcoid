class AdminEmail < ApplicationRecord
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :email, format: { with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i, message: "must be a valid email address" }
  validates :main, inclusion: { in: [true, false] }
end
