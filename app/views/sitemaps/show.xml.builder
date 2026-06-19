xml.instruct! :xml, version: '1.0', encoding: 'UTF-8'
xml.urlset xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9' do
  # Static Pages
  xml.url do
    xml.loc root_url
    xml.changefreq 'daily'
    xml.priority 1.0
  end

  xml.url do
    xml.loc about_url
    xml.changefreq 'monthly'
    xml.priority 0.8
  end

  xml.url do
    xml.loc new_contact_url
    xml.changefreq 'monthly'
    xml.priority 0.8
  end

  # Resource Indexes
  xml.url do
    xml.loc courses_url
    xml.changefreq 'weekly'
    xml.priority 0.9
  end

  xml.url do
    xml.loc class_schedules_url
    xml.changefreq 'daily'
    xml.priority 0.9
  end

  xml.url do
    xml.loc meetups_url
    xml.changefreq 'daily'
    xml.priority 0.9
  end

  xml.url do
    xml.loc resources_url
    xml.changefreq 'weekly'
    xml.priority 0.8
  end

  xml.url do
    xml.loc blog_posts_url
    xml.changefreq 'daily'
    xml.priority 0.8
  end

  # Dynamic Courses
  @courses.find_each do |course|
    xml.url do
      xml.loc course_url(course)
      xml.lastmod course.updated_at.to_date.to_s
      xml.changefreq 'weekly'
      xml.priority 0.8
    end
  end

  # Dynamic Class Schedules (/class_schedules/:course_slug/:id)
  @class_schedules.each do |class_schedule|
    xml.url do
      xml.loc class_schedule_url(class_schedule)
      xml.lastmod class_schedule.updated_at.to_date.to_s
      xml.changefreq 'daily'
      xml.priority 0.8
    end
  end

  # Dynamic Meetups
  @meetups.find_each do |meetup|
    xml.url do
      xml.loc meetup_url(meetup)
      xml.lastmod meetup.updated_at.to_date.to_s
      xml.changefreq 'daily'
      xml.priority 0.8
    end
  end

  # Dynamic Resources
  @resources.find_each do |resource|
    xml.url do
      xml.loc resource_url(resource)
      xml.lastmod resource.updated_at.to_date.to_s
      xml.changefreq 'weekly'
      xml.priority 0.7
    end
  end

  # Dynamic Blog Posts
  @blog_posts.find_each do |blog_post|
    xml.url do
      xml.loc blog_post_url(blog_post)
      xml.lastmod blog_post.updated_at.to_date.to_s
      xml.changefreq 'weekly'
      xml.priority 0.7
    end
  end
end
