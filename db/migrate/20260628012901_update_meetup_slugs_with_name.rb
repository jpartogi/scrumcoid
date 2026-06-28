class UpdateMeetupSlugsWithName < ActiveRecord::Migration[8.1]
  class Meetup < ApplicationRecord
    self.table_name = "meetups"
  end

  def up
    grouped = Meetup.all.group_by do |meetup|
      time_zone = ActiveSupport::TimeZone[meetup.timezone] || Time.zone
      date_prefix = meetup.starts_at.in_time_zone(time_zone).to_date.strftime("%Y-%m-%d")
      "#{meetup.name.to_s.parameterize}-#{date_prefix}"
    end

    grouped.each do |slug_prefix, meetups|
      meetups.sort_by(&:id).each_with_index do |meetup, index|
        slug = index.zero? ? slug_prefix : "#{slug_prefix}-#{index + 1}"
        meetup.update_column(:slug, slug)
      end
    end
  end

  def down
    grouped = Meetup.all.group_by do |meetup|
      time_zone = ActiveSupport::TimeZone[meetup.timezone] || Time.zone
      meetup.starts_at.in_time_zone(time_zone).to_date.strftime("%Y-%m-%d")
    end

    grouped.each do |date_prefix, meetups|
      meetups.sort_by(&:id).each_with_index do |meetup, index|
        meetup.update_column(:slug, "#{date_prefix}-#{index + 1}")
      end
    end
  end
end