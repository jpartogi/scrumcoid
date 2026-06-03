class UniqueVisit < ApplicationRecord
  validates :fingerprint, :visited_on, presence: true

  scope :today, -> { where(visited_on: Date.today) }
  scope :yesterday, -> { where(visited_on: Date.yesterday) }
  scope :last_7_days, -> { where(visited_on: (Date.today - 6)..Date.today) }
  scope :last_30_days, -> { where(visited_on: (Date.today - 29)..Date.today) }

  # Prune old visit records to keep the table small. Call periodically (e.g. via job).
  # retention_days: how many days of history to keep (default 90 for ~3 months of stats).
  def self.prune_old!(retention_days: 90)
    cutoff = retention_days.days.ago.to_date
    deleted = where("visited_on < ?", cutoff).delete_all
    Rails.logger.info "Pruned #{deleted} old UniqueVisit records (retention: #{retention_days} days)" if deleted > 0
    deleted
  end

  # Distinct count of visitors (by fingerprint) over a date range.
  # Useful for "unique visitors in last N days" (union, not sum of daily).
  def self.distinct_count_in_range(range)
    where(visited_on: range).distinct.count(:fingerprint)
  end
end
