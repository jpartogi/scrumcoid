class UniqueVisit < ApplicationRecord
  validates :ip_hash, :visited_on, presence: true
  validates :ip_hash, uniqueness: { scope: :visited_on }

  scope :today, -> { where(visited_on: Date.today) }
  scope :yesterday, -> { where(visited_on: Date.yesterday) }
  scope :last_7_days, -> { where(visited_on: 6.days.ago.to_date..Date.today) }
end
