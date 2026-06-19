class ResourceDownloadRequest < ApplicationRecord
  JOB_TITLE_LABELS = {
    "product_owner_manager" => "Product Owner/Product Manager",
    "scrum_master_coach" => "Scrum Master/Coach",
    "it_manager" => "IT Manager",
    "project_manager" => "Project Manager",
    "business_analyst" => "Business Analyst",
    "lead_engineer" => "Lead Engineer",
    "other" => "Lainnya"
  }.freeze

  enum :job_title, {
    product_owner_manager: 0,
    scrum_master_coach: 1,
    it_manager: 2,
    project_manager: 3,
    business_analyst: 4,
    lead_engineer: 5,
    other: 6
  }

  belongs_to :resource

  before_validation :assign_token, on: :create

  validates :visitor_name, :visitor_email, :job_title, :token, presence: true
  validates :visitor_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :resource_accepts_download_request, on: :create

  def job_title_label
    JOB_TITLE_LABELS[job_title]
  end

  def send_download_email!
    ResourceMailer.download_link(self).deliver_later
    update!(email_sent_at: Time.current)
  end

  def self.job_title_options
    job_titles.keys.map { |key| [JOB_TITLE_LABELS[key], key] }
  end

  def self.download_counts_for(resource_ids)
    return {} if resource_ids.blank?

    where(resource_id: resource_ids).group(:resource_id).count
  end

  private

  def assign_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def resource_accepts_download_request
    return if resource.blank?

    unless resource.available_for_email_download?
      errors.add(:resource, "is not available for email download")
    end
  end
end