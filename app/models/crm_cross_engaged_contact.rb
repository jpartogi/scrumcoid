class CrmCrossEngagedContact < ApplicationRecord
  self.table_name = "resource_download_requests"
  self.primary_key = "normalized_email"

  def self.all_scope(query: nil)
    relation = scoped_from_subquery

    if query.present?
      term = "%#{sanitize_sql_like(query.to_s.strip.downcase)}%"
      relation = relation.where(
        "LOWER(visitor_email) LIKE :q OR LOWER(resource_visitor_name) LIKE :q OR LOWER(meetup_visitor_name) LIKE :q",
        q: term
      )
    end

    relation.order(Arel.sql("last_meetup_registration_at DESC, last_resource_download_at DESC"))
  end

  def self.total_count
    scoped_from_subquery.count
  end

  def self.scoped_from_subquery
    unscoped.from("(#{cross_engaged_subquery}) AS resource_download_requests")
  end

  def readonly?
    true
  end

  def display_name
    names = [resource_visitor_name, meetup_visitor_name].compact_blank.uniq
    names.presence&.join(" · ") || visitor_email
  end

  def last_resource_download_at
    cast_timestamp(self[:last_resource_download_at])
  end

  def last_meetup_registration_at
    cast_timestamp(self[:last_meetup_registration_at])
  end

  def self.cast_timestamp(value)
    return if value.blank?
    return value if value.is_a?(Time) || value.is_a?(ActiveSupport::TimeWithZone) || value.is_a?(DateTime)

    Time.zone.parse(value.to_s)
  end

  def cast_timestamp(value)
    self.class.cast_timestamp(value)
  end

  private_class_method def self.cross_engaged_subquery
    latest_resource_title_sql = <<~SQL.squish
      (
        SELECT resources.title
        FROM resource_download_requests latest_download
        INNER JOIN resources ON resources.id = latest_download.resource_id
        WHERE LOWER(latest_download.visitor_email) = leads.normalized_email
        ORDER BY latest_download.created_at DESC
        LIMIT 1
      )
    SQL

    latest_meetup_name_sql = <<~SQL.squish
      (
        SELECT meetups.name
        FROM meetup_registrations latest_registration
        INNER JOIN meetups ON meetups.id = latest_registration.meetup_id
        WHERE LOWER(latest_registration.visitor_email) = leads.normalized_email
        ORDER BY latest_registration.created_at DESC
        LIMIT 1
      )
    SQL

    <<~SQL.squish
      SELECT
        leads.normalized_email,
        downloads.resource_visitor_name,
        COALESCE(downloads.visitor_email, meetups.visitor_email) AS visitor_email,
        COALESCE(downloads.resource_download_count, 0) AS resource_download_count,
        downloads.last_resource_download_at,
        #{latest_resource_title_sql} AS latest_resource_title,
        meetups.meetup_visitor_name,
        COALESCE(meetups.meetup_registration_count, 0) AS meetup_registration_count,
        meetups.last_meetup_registration_at,
        #{latest_meetup_name_sql} AS latest_meetup_name
      FROM (
        SELECT LOWER(visitor_email) AS normalized_email
        FROM resource_download_requests
        UNION
        SELECT LOWER(visitor_email) AS normalized_email
        FROM meetup_registrations
      ) AS leads
      LEFT JOIN (
        SELECT
          LOWER(visitor_email) AS normalized_email,
          MAX(visitor_name) AS resource_visitor_name,
          MAX(visitor_email) AS visitor_email,
          COUNT(*) AS resource_download_count,
          MAX(created_at) AS last_resource_download_at
        FROM resource_download_requests
        GROUP BY LOWER(visitor_email)
      ) AS downloads ON downloads.normalized_email = leads.normalized_email
      LEFT JOIN (
        SELECT
          LOWER(visitor_email) AS normalized_email,
          MAX(visitor_name) AS meetup_visitor_name,
          MAX(visitor_email) AS visitor_email,
          COUNT(*) AS meetup_registration_count,
          MAX(created_at) AS last_meetup_registration_at
        FROM meetup_registrations
        GROUP BY LOWER(visitor_email)
      ) AS meetups ON meetups.normalized_email = leads.normalized_email
    SQL
  end
end