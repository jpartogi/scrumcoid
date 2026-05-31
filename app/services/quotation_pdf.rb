require "prawn"
require "prawn/table"

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

    # Header
    pdf.font_size 10
    pdf.text "QUOTATION / PENAWARAN HARGA", size: 16, style: :bold, align: :center
    pdf.move_down 20

    # Company info (you can customize this)
    pdf.text "PT. Scrumcoid Indonesia", size: 12, style: :bold
    pdf.text "Email: admin@scrumcoid.com | Telp: +62 xxx xxxx xxxx"
    pdf.move_down 15

    # Quotation details
    pdf.text "Quotation Number: QT-#{@registration.id.to_s.rjust(5, '0')}", size: 10
    pdf.text "Date: #{Date.current.strftime('%d %B %Y')}", size: 10
    pdf.move_down 15

    # Bill To
    pdf.text "Bill To:", style: :bold
    pdf.text @registration.finance_name
    pdf.text @registration.company_name
    pdf.text @registration.company_address.to_s
    pdf.text "Email: #{@registration.finance_email}"
    pdf.text "Phone: #{@registration.company_phone}"
    pdf.move_down 15

    # Training details
    pdf.text "Training Details", style: :bold, size: 11
    pdf.move_down 5

    data = [
      ["Training", @course.title],
      ["Schedule", @schedule.starts_at.strftime("%d %B %Y") + " - " + @schedule.ends_at.strftime("%d %B %Y")],
      ["Location", @schedule.online? ? "Online" : @schedule.location],
      ["Number of Participants", @registration.total_participants.to_s]
    ]

    pdf.table(data, column_widths: [150, 300]) do |t|
      t.cells.borders = []
      t.cells.padding = 3
    end

    pdf.move_down 20

    # Participants list
    pdf.text "Participants", style: :bold, size: 11
    pdf.move_down 5

    participant_data = [["No", "Full Name", "Email"]]
    @registration.enrollments.each_with_index do |enrollment, index|
      participant_data << [index + 1, enrollment.visitor_name || enrollment.attendee_name, enrollment.visitor_email || enrollment.attendee_email]
    end

    pdf.table(participant_data, header: true, column_widths: [30, 200, 220]) do |t|
      t.header = true
      t.row(0).font_style = :bold
      t.cells.borders = [:bottom]
      t.cells.padding = 5
    end

    pdf.move_down 30

    # Pricing (you can improve this later with actual pricing)
    pdf.text "Quotation will be calculated based on the number of participants and current pricing.", size: 9, style: :italic
    pdf.move_down 10
    pdf.text "Please reply to this email or contact us to proceed with the payment after receiving the official quotation.", size: 9

    pdf.render
  end
end
