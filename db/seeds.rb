admin = User.find_or_create_by!(email: "admin@scrumai.example") do |user|
  user.name = "Admin Trainer"
  user.password = "password123"
  user.role = :admin
end

student = User.find_or_create_by!(email: "student@scrumai.example") do |user|
  user.name = "Budi Santoso"
  user.password = "password123"
  user.role = :student
end

# 1. Professional Scrum Master I (PSM I)
course_psm = Course.find_or_initialize_by(slug: "professional-scrum-master-i")
course_psm.update!(
  title: "Professional Scrum Master I (PSM I)",
  excerpt: "Pelatihan resmi Scrum.org untuk menguasai peran Scrum Master secara profesional di Indonesia.",
  description: "Kursus dua hari yang interaktif ini membekali peserta dengan pemahaman mendalam tentang kerangka kerja Scrum dan peran Scrum Master. Peserta akan mempelajari dasar-dasar empiris Scrum, bagaimana membimbing tim agar berkinerja tinggi, cara memfasilitasi kolaborasi mandiri, dan cara mengatasi hambatan sistemik dalam organisasi untuk mencapai tujuan bisnis.",
  status: :published
)

# 2. Professional Scrum Product Owner I (PSPO I)
course_pspo = Course.find_or_initialize_by(slug: "professional-scrum-product-owner-i")
course_pspo.update!(
  title: "Professional Scrum Product Owner I (PSPO I)",
  excerpt: "Maksimalkan nilai produk dan tingkatkan ROI bisnis Anda melalui efektivitas peran Product Owner.",
  description: "Pelatihan komprehensif bagi para Product Owner, manajer produk, dan analis bisnis untuk menguasai manajemen produk yang tangkas. Pelajari cara mengelola Product Backlog secara optimal, menyelaraskan visi bisnis dengan kebutuhan pasar, mengukur metrik nilai, dan memaksimalkan nilai yang dihasilkan oleh tim pengembang.",
  status: :published
)

# 3. Professional Scrum Developer (PSD)
course_psd = Course.find_or_initialize_by(slug: "professional-scrum-developer")
course_psd.update!(
  title: "Professional Scrum Developer (PSD)",
  excerpt: "Pelatihan praktis bagi tim pengembang untuk berkolaborasi membangun perangkat lunak berkualitas tinggi.",
  description: "Kelas berbasis praktik langsung bagi para insinyur perangkat lunak, arsitek, perancang, dan penguji untuk mempelajari cara berkolaborasi dalam satu Sprint. Fokus pada penerapan praktik rekayasa perangkat lunak modern seperti Test-Driven Development (TDD), Integrasi Berkelanjutan (CI), kepemilikan kode kolektif, dan peningkatan kualitas teknis.",
  status: :published
)

# Set Course Prices
[course_psm, course_pspo, course_psd].each do |course|
  course.course_prices.find_or_create_by!(currency: "IDR") { |price| price.amount = 8500000.00 }
  course.course_prices.find_or_create_by!(currency: "USD") { |price| price.amount = 595.00 }
  course.course_prices.find_or_create_by!(currency: "AUD") { |price| price.amount = 900.00 }
end

# Class Schedules
[
  [course_psm, 21.days.from_now, "Live Online via Zoom", true, "Asia/Jakarta", nil, nil],
  [course_psm, 45.days.from_now, "Jakarta, Indonesia", false, "Asia/Jakarta", "Hotel Santika Premiere Slipi", "Jl. Aipda KS Tubun No.7, Jakarta"],
  [course_pspo, 30.days.from_now, "Live Online via Zoom", true, "Asia/Jakarta", nil, nil],
  [course_psd, 60.days.from_now, "Bandung, Indonesia", false, "Asia/Jakarta", "Sheraton Bandung Hotel & Towers", "Jl. Ir. H. Juanda No.390, Bandung"]
].each do |course, starts_at, location, online, timezone, venue_name, venue_address|
  ClassSchedule.find_or_create_by!(course: course, starts_at: starts_at.change(hour: 9, min: 0, sec: 0)) do |schedule|
    schedule.ends_at = starts_at.change(hour: 17, min: 0, sec: 0)
    schedule.location = location
    schedule.online = online
    schedule.timezone = timezone
    schedule.capacity = 25
    schedule.registration_deadline = starts_at.change(hour: 17, min: 0, sec: 0) - 5.days
    schedule.status = :published
    schedule.venue_name = venue_name
    schedule.venue_address = venue_address
  end
end

# Blog Posts in Bahasa Indonesia from JSON
require 'json'
require 'nokogiri'

def extract_excerpt(item)
  raw_excerpt = item['excerpt'].to_s.strip
  if raw_excerpt.present?
    excerpt_text = ActionController::Base.helpers.strip_tags(raw_excerpt)
    return excerpt_text.strip if excerpt_text.present?
  end

  body_doc = Nokogiri::HTML::DocumentFragment.parse(item['body'])
  subtitle_node = body_doc.at_css('.article-subtitle')
  if subtitle_node
    excerpt_text = subtitle_node.text.strip
    return excerpt_text if excerpt_text.present?
  end

  body_doc.css('p').each do |p|
    p_text = p.text.strip
    if p_text.present? && p_text.size > 20
      return p_text.truncate(200)
    end
  end

  "Mengenali pola kepemilikan produk yang disukai dan yang sering disalahpahami."
end

def preprocess_body(html_content)
  doc = Nokogiri::HTML::DocumentFragment.parse(html_content)
  
  # Remove all <style> tags to avoid layout pollution
  doc.css('style').remove

  # Unwrap structural layout container divs
  loop do
    wrappers = doc.css('div').select do |div|
      cls = div['class'].to_s
      cls.include?('sqs-') || cls.include?('row') || cls.include?('col') || cls.include?('span-') || cls.include?('block')
    end
    break if wrappers.empty?
    wrappers.each do |node|
      node.replace(node.children)
    end
  end

  # Clean paragraphs from legacy inline styles
  doc.css('p').each do |p|
    p.remove_attribute('style')
    p.remove_attribute('class') if p['class'].blank?
  end
  
  doc.css('img').each do |img|
    data_src = img['data-src'] || img['src']
    if data_src.present?
      if data_src.include?('squarespace-cdn.com') && !data_src.include?('format=')
        data_src = "#{data_src}?format=1000w"
      end
      img['src'] = data_src
      img.remove_attribute('data-src')
      img['class'] = [img['class'], 'img-fluid', 'rounded', 'my-4'].compact.join(' ')
      img['style'] = "max-width: 100%; height: auto; display: block; margin-left: auto; margin-right: auto;"
    end
  end

  doc.css('a').each do |a|
    href = a['href']
    if href.present?
      if href =~ %r{https?://(?:www\.)?scrum\.co\.id/blog/([^/]+)}
        a['href'] = "/blog/#{$1}"
      elsif href =~ %r{https?://(?:www\.)?scrum\.co\.id/scrum-training/([^/]+)}
        a['href'] = "/courses/#{$1}"
      elsif href == "http://www.scrum.co.id" || href == "https://www.scrum.co.id" || href == "/"
        a['href'] = "/"
      end
    end
  end

  doc.to_html
end

json_file = Rails.root.join("db", "seeds", "blog_posts.json")
if File.exist?(json_file)
  data = JSON.parse(File.read(json_file))
  BlogPost.destroy_all
  data['items'].each do |item|
    BlogPost.create!(
      title: item['title'],
      slug: item['urlId'],
      excerpt: extract_excerpt(item),
      body: preprocess_body(item['body']),
      published_at: Time.at(item['publishOn'] / 1000.0),
      status: :published
    )
  end
end


# About Page in Bahasa Indonesia
AboutPage.current.update!(
  title: "Tentang scrum.co.id",
  summary: "Pusat pelatihan dan edukasi Scrum Profesional terkemuka di Indonesia untuk membangun tim produk yang tangguh dan berkinerja tinggi.",
  body: "scrum.co.id berkomitmen penuh meningkatkan standar profesionalisme manajemen produk dan rekayasa perangkat lunak di Indonesia melalui pelatihan Scrum bersertifikat internasional resmi dari Scrum.org.\n\nPelatihan kami menggabungkan standar global, pengalaman langsung memandu transformasi digital berskala besar di tanah air, serta pendekatan fasilitasi yang pragmatis dan interaktif."
)

# Student Enrollment
Enrollment.find_or_create_by!(user: student, class_schedule: ClassSchedule.published.first)

puts "Seeded #{Course.count} courses, #{ClassSchedule.count} schedules, #{BlogPost.count} blog posts, #{AboutPage.count} about page, and users: #{admin.email}, #{student.email}"
