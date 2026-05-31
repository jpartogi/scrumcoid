class Venue < ApplicationRecord
  has_many :class_schedules, dependent: :nullify

  validates :name, :address, presence: true

  def to_s
    name
  end
end
