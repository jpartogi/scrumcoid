class PageView < ApplicationRecord
  belongs_to :viewable, polymorphic: true

  validates :fingerprint, :viewed_on, presence: true

  scope :today, -> { where(viewed_on: Date.today) }
  scope :yesterday, -> { where(viewed_on: Date.yesterday) }
  scope :last_7_days, -> { where(viewed_on: (Date.today - 6)..Date.today) }
  scope :last_30_days, -> { where(viewed_on: (Date.today - 29)..Date.today) }

  def self.track!(viewable:, fingerprint:, viewed_on: Date.today)
    create_or_find_by!(viewable: viewable, fingerprint: fingerprint, viewed_on: viewed_on)
  end

  def self.prune_old!(retention_days: 90)
    cutoff = retention_days.days.ago.to_date
    deleted = where("viewed_on < ?", cutoff).delete_all
    Rails.logger.info "Pruned #{deleted} old PageView records (retention: #{retention_days} days)" if deleted > 0
    deleted
  end

  def self.distinct_count_in_range(viewable:, range:)
    where(viewable: viewable, viewed_on: range).distinct.count(:fingerprint)
  end

  def self.unique_view_counts_for(viewable_type, viewable_ids)
    return {} if viewable_ids.blank?

    where(viewable_type: viewable_type, viewable_id: viewable_ids)
      .group(:viewable_id)
      .count("DISTINCT fingerprint")
  end
end