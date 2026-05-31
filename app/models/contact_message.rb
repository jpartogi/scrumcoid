class ContactMessage < ApplicationRecord
  enum :status, { unread: 0, read: 1, archived: 2 }

  attr_accessor :jenis_inkuiri, :pelatihan

  validates :name, :email, :subject, :message, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :set_subject_from_dropdowns

  scope :recent, -> { order(created_at: :desc) }

  private

  def set_subject_from_dropdowns
    if jenis_inkuiri.present? || pelatihan.present?
      self.subject = [jenis_inkuiri, pelatihan].reject(&:blank?).join(" - ")
    end
  end
end
