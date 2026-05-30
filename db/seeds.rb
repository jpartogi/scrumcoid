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
  [course_psm, 21.days.from_now, "Live Online via Zoom", true, "Asia/Jakarta"],
  [course_psm, 45.days.from_now, "Jakarta, Indonesia", false, "Asia/Jakarta"],
  [course_pspo, 30.days.from_now, "Live Online via Zoom", true, "Asia/Jakarta"],
  [course_psd, 60.days.from_now, "Bandung, Indonesia", false, "Asia/Jakarta"]
].each do |course, starts_at, location, online, timezone|
  ClassSchedule.find_or_create_by!(course: course, starts_at: starts_at.change(hour: 9, min: 0, sec: 0)) do |schedule|
    schedule.ends_at = starts_at.change(hour: 17, min: 0, sec: 0)
    schedule.location = location
    schedule.online = online
    schedule.timezone = timezone
    schedule.capacity = 25
    schedule.registration_deadline = starts_at.change(hour: 17, min: 0, sec: 0) - 5.days
    schedule.status = :published
    
    # Build prices here to pass validation
    schedule.class_schedule_prices.build(currency: "IDR", amount: 8500000.00)
    schedule.class_schedule_prices.build(currency: "USD", amount: 595.00)
    schedule.class_schedule_prices.build(currency: "AUD", amount: 900.00)
    schedule.class_schedule_prices.build(currency: "EUR", amount: 550.00)
  end
end

# Blog Posts in Bahasa Indonesia
BlogPost.find_or_create_by!(slug: "panduan-praktis-memulai-scrum-di-indonesia") do |post|
  post.title = "Panduan Praktis Memulai Scrum di Indonesia"
  post.excerpt = "Banyak tim di Indonesia menghadapi tantangan budaya saat mengadopsi Scrum. Berikut adalah langkah praktis untuk mengatasinya secara efektif."
  post.body = "Mengadopsi Scrum di Indonesia seringkali menuntut perubahan pola pikir dari manajemen hierarkis tradisional menuju kolaborasi mandiri dan keterbukaan. Mulailah dengan transparansi penuh atas pekerjaan, adakan retrospektif berkala dengan jujur, dan dorong akuntabilitas tim tanpa rasa takut salah.\n\nFokuslah pada nilai-nilai dasar Scrum seperti keterbukaan dan keberanian untuk melakukan perbaikan berkelanjutan di setiap Sprint."
  post.status = :published
  post.published_at = 3.days.ago
end

BlogPost.find_or_create_by!(slug: "meningkatkan-kolaborasi-tim-scrum-jarak-jauh") do |post|
  post.title = "Meningkatkan Kolaborasi Tim Scrum Jarak Jauh"
  post.excerpt = "Panduan praktis menjaga keterlibatan, keselarasan, dan transparansi tim Scrum yang bekerja dari rumah (WFH) secara efisien."
  post.body = "Kerja jarak jauh menuntut disiplin tinggi dalam komunikasi dan transparansi. Gunakan papan digital visual untuk memperbarui status pekerjaan, pertahaman Daily Scrum yang konsisten dan interaktif tepat waktu, serta buat kesepakatan tim (Working Agreements) yang jelas mengenai jam kerja kolaboratif.\n\nPastikan Sprint Retrospective tetap diadakan untuk menilai efektivitas kolaborasi virtual tim Anda."
  post.status = :published
  post.published_at = 1.day.ago
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
