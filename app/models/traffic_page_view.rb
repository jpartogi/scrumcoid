class TrafficPageView < ApplicationRecord
  validates :path, :fingerprint, :viewed_on, presence: true

  scope :in_reporting_period, ->(days) { where(viewed_on: reporting_date_range(days)) }

  class << self
    def track!(path:, fingerprint:, viewed_on: UniqueVisit.reporting_today)
      normalized_path = normalize_path(path)
      return if normalized_path.blank?

      create_or_find_by!(path: normalized_path, fingerprint: fingerprint, viewed_on: viewed_on)
    end

    def prune_old!(retention_days: 90)
      cutoff = UniqueVisit.reporting_today - retention_days
      deleted = where("viewed_on < ?", cutoff).delete_all
      Rails.logger.info "Pruned #{deleted} old TrafficPageView records (retention: #{retention_days} days)" if deleted > 0
      deleted
    end

    def reporting_date_range(days)
      end_date = UniqueVisit.reporting_today
      start_date = end_date - (days - 1)
      start_date..end_date
    end

    def normalize_path(path)
      normalized = path.to_s.strip
      return "/" if normalized.blank?

      normalized = "/#{normalized}" unless normalized.start_with?("/")
      normalized = normalized.chomp("/")
      normalized.presence || "/"
    end
  end
end