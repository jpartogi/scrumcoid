class ContactMessage < ApplicationRecord
  enum :status, { unread: 0, read: 1, archived: 2 }

  validates :name, :email, :subject, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :recent, -> { order(created_at: :desc) }
end
