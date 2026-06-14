class MigrateUniqueVisitsToUtcVisitedAt < ActiveRecord::Migration[8.1]
  REPORTING_TIMEZONE = "Australia/Brisbane"

  def up
    add_column :unique_visits, :visited_at, :datetime
    add_column :unique_visits, :timezone, :string, null: false, default: REPORTING_TIMEZONE

    backfill_visited_at_from_visited_on

    change_column_null :unique_visits, :visited_at, false

    remove_index :unique_visits, name: "index_unique_visits_on_fingerprint_and_visited_on", if_exists: true
    remove_index :unique_visits, name: "index_unique_visits_on_visited_on", if_exists: true
    remove_column :unique_visits, :visited_on

    add_index :unique_visits, :visited_at
    add_index :unique_visits, [:fingerprint, :visited_at]
  end

  def down
    add_column :unique_visits, :visited_on, :date

    backfill_visited_on_from_visited_at

    change_column_null :unique_visits, :visited_on, false

    remove_index :unique_visits, [:fingerprint, :visited_at], if_exists: true
    remove_index :unique_visits, :visited_at, if_exists: true
    remove_column :unique_visits, :visited_at
    remove_column :unique_visits, :timezone

    add_index :unique_visits, [:fingerprint, :visited_on], unique: true
    add_index :unique_visits, :visited_on
  end

  private

  def backfill_visited_at_from_visited_on
    zone = ActiveSupport::TimeZone[REPORTING_TIMEZONE]

    say_with_time "Backfilling visited_at from visited_on (#{REPORTING_TIMEZONE})" do
      UniqueVisit.reset_column_information

      UniqueVisit.find_each do |visit|
        date = visit.read_attribute(:visited_on)
        next unless date

        visited_at = zone.local(date.year, date.month, date.day, 12, 0, 0).utc
        visit.update_columns(visited_at: visited_at, timezone: REPORTING_TIMEZONE)
      end
    end
  end

  def backfill_visited_on_from_visited_at
    zone = ActiveSupport::TimeZone[REPORTING_TIMEZONE]

    say_with_time "Backfilling visited_on from visited_at (#{REPORTING_TIMEZONE})" do
      UniqueVisit.reset_column_information

      UniqueVisit.find_each do |visit|
        visited_at = visit.read_attribute(:visited_at)
        next unless visited_at

        timezone = visit.read_attribute(:timezone).presence || REPORTING_TIMEZONE
        visited_on = visited_at.in_time_zone(timezone).to_date
        visit.update_columns(visited_on: visited_on)
      end
    end
  end
end