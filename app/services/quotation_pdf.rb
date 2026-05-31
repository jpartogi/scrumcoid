require "prawn"
require "prawn/table"

Prawn::Fonts::AFM.hide_m17n_warning = true

class QuotationPdf
  def self.generate(registration)
    new(registration).generate
  end

  def initialize(registration)
    @registration = registration
    @course = registration.course
    @schedule = registration.class_schedule
  end

  def generate
    pdf = Prawn::Document.new(page_size: "A4", margin: 50)

    # PT info top left
    pdf.bounding_box([0, pdf.bounds.height], width: 495, height: 50) do
      pdf.bounding_box([0, 50], width: 320, height: 50) do
        pdf.text "PT. Adaptiva Sinergi Asia", size: 14, style: :bold, color: "0F172A"
        pdf.text "Email: jessica.stella@scrum.co.id | Telp: +62 856 4342 8348", size: 8, color: "475569"
        pdf.text "Website: scrum.co.id", size: 8, color: "475569"
      end
    end

    pdf.move_down 10
    pdf.stroke_color "1E3A8A" # Indigo/Blue accent line
    pdf.line_width = 2
    pdf.stroke_horizontal_rule
    pdf.move_down 20

    # Side-by-side: Bill To and Quotation Details
    pdf.bounding_box([0, pdf.cursor], width: 495, height: 110) do
      # Bill To (Left side)
      pdf.bounding_box([0, 110], width: 260, height: 110) do
        pdf.text "Kepada / Bill To:", style: :bold, size: 9, color: "475569"
        pdf.move_down 4
        pdf.text @registration.finance_name, size: 11, style: :bold, color: "0F172A"
        pdf.text @registration.company_name, size: 10, style: :bold, color: "1E293B"
        pdf.text @registration.company_address.to_s, size: 8.5, color: "475569"
        pdf.text "Email: #{@registration.finance_email}", size: 8.5, color: "475569"
        pdf.text "Telp: #{@registration.company_phone}", size: 8.5, color: "475569"
      end

      # Quotation Details (Right side)
      pdf.bounding_box([275, 110], width: 220, height: 110) do
        pdf.text "PENAWARAN HARGA", size: 14, style: :bold, color: "1E3A8A", align: :right
        pdf.text "QUOTATION", size: 8, style: :bold, color: "64748B", align: :right
        pdf.move_down 10
        pdf.text "Nomor: QT-#{@registration.id.to_s.rjust(5, '0')}", size: 10, style: :bold, color: "0F172A", align: :right
        pdf.text "Tanggal: #{Date.current.strftime('%d %B %Y')}", size: 9, color: "475569", align: :right
      end
    end

    pdf.move_down 20

    # Section 1: Training details
    pdf.text "Detail Pelatihan", style: :bold, size: 12, color: "0F172A"
    pdf.move_down 6

    data = [
      ["Nama Pelatihan", @course.title],
      ["Jadwal", formatted_date_range],
      ["Lokasi", @schedule.online? ? "Online Langsung (Zoom/Teams)" : @schedule.location],
      ["Jumlah Peserta", "#{@registration.total_participants} Orang"]
    ]

    pdf.table(data, column_widths: [120, 375]) do |t|
      t.cells.size = 11
      t.cells.borders = [:bottom]
      t.cells.border_width = 0.5
      t.cells.border_color = "E2E8F0"
      t.cells.padding = [6, 8]
      t.column(0).font_style = :bold
      t.column(0).text_color = "475569"
      t.column(1).text_color = "0F172A"
    end

    pdf.move_down 25

    # Section 2: Participants list
    pdf.text "Daftar Peserta", style: :bold, size: 12, color: "0F172A"
    pdf.move_down 6

    participant_data = [["No.", "Nama Lengkap", "Email"]]
    @registration.enrollments.each_with_index do |enrollment, index|
      participant_data << [
        (index + 1).to_s, 
        enrollment.visitor_name || enrollment.attendee_name || "", 
        enrollment.visitor_email || enrollment.attendee_email || ""
      ]
    end

    pdf.table(participant_data, header: true, column_widths: [45, 230, 220]) do |t|
      t.header = true
      t.cells.size = 11
      t.row(0).background_color = "0F172A"
      t.row(0).text_color = "FFFFFF"
      t.row(0).font_style = :bold
      t.row(0).padding = [8, 10]
      t.row_colors = ["F8FAFC", "FFFFFF"]
      t.cells.borders = [:bottom]
      t.cells.border_width = 0.5
      t.cells.border_color = "E2E8F0"
      t.cells.padding = [6, 10]
      t.column(0).align = :center
    end

    pdf.move_down 40

    # Separator Line for Footer Note
    pdf.stroke_color "E2E8F0"
    pdf.line_width = 0.5
    pdf.stroke_horizontal_rule
    pdf.move_down 15

    # Pricing & Info note
    pdf.text "Catatan Penting:", style: :bold, size: 9, color: "0F172A"
    pdf.move_down 4
    pdf.text "• Penawaran harga akan dihitung berdasarkan jumlah peserta dan harga yang berlaku saat ini.", size: 8.5, style: :italic, color: "475569"
    pdf.text "• Silakan balas email ini atau hubungi kami untuk melanjutkan pembayaran setelah menerima penawaran resmi.", size: 8.5, color: "475569"

    pdf.render
  end

  private

  def formatted_date_range
    starts_at = @schedule.starts_at.in_time_zone(@schedule.time_zone || Time.zone)
    ends_at = @schedule.ends_at.in_time_zone(@schedule.time_zone || Time.zone)

    start_day = starts_at.day
    end_day = ends_at.day
    start_month = starts_at.strftime("%B")
    end_month = ends_at.strftime("%B")
    year = starts_at.year
    start_time = starts_at.strftime("%-l:%M %p")
    end_time = ends_at.strftime("%-l:%M %p")
    timezone_name = @schedule.time_zone&.tzinfo&.name || @schedule.timezone

    range_str = if starts_at.to_date == ends_at.to_date
      # Same day
      "#{start_day} #{start_month} #{year} #{start_time} - #{end_time}"
    elsif starts_at.month == ends_at.month && starts_at.year == ends_at.year
      # Same month, different days
      "#{start_day} - #{end_day} #{start_month} #{year} #{start_time} - #{end_time}"
    else
      # Different months
      "#{start_day} #{start_month} - #{end_day} #{end_month} #{year} #{start_time} - #{end_time}"
    end

    "#{range_str}"
  end
end
