class TrafficPageLabeler
  STATIC_LABELS = {
    "/" => "Home",
    "/about" => "About",
    "/blog" => "Blog",
    "/class_schedules" => "Class Schedules",
    "/contact" => "Contact",
    "/courses" => "Courses",
    "/dashboard" => "Student Dashboard",
    "/meetups" => "Meetups",
    "/resources" => "Resources"
  }.freeze

  def label(path)
    STATIC_LABELS[path] || dynamic_label(path) || path
  end

  private

  def dynamic_label(path)
    case path
    when %r{\A/courses/([^/]+)\z}
      course_title(Course.find_by(slug: Regexp.last_match(1)))
    when %r{\A/blog/([^/]+)\z}
      record_title("Blog Post", BlogPost.find_by(slug: Regexp.last_match(1)))
    when %r{\A/resources/([^/]+)\z}
      record_title("Resource", Resource.find_by(slug: Regexp.last_match(1)))
    when %r{\A/meetups/([^/]+)\z}
      meetup = Meetup.find_by(slug: Regexp.last_match(1))
      meetup ? "Meetup: #{meetup.display_name}" : nil
    when %r{\A/class_schedules/[^/]+/(\d+)\z}
      schedule = ClassSchedule.includes(:course).find_by(id: Regexp.last_match(1))
      schedule ? "Class: #{schedule.course.title}" : nil
    when %r{\A/resources/[^/]+/download_requests/new\z}
      "Resource Download"
    when %r{\A/meetups/[^/]+/registrations/new\z}
      "Meetup Registration"
    when %r{\A/class_schedules/[^/]+/registrations/new\z}
      "Class Registration"
    end
  end

  def course_title(course)
    course ? "Course: #{course.title}" : nil
  end

  def record_title(prefix, record)
    record ? "#{prefix}: #{record.title}" : nil
  end
end