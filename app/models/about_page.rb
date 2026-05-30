class AboutPage < ApplicationRecord
  has_rich_text :body

  validates :title, :summary, :body, presence: true

  def self.current
    first_or_create!(
      title: "About scrum.co.id",
      summary: "Professional Scrum education and training for teams and leaders.",
      body: "scrum.co.id helps Scrum teams, leaders, and educators improve product outcomes through practical, empirical approaches."
    )
  end
end
