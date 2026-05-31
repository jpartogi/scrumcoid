class ContactMessagesController < ApplicationController
  def new
    @contact_message = ContactMessage.new
    
    if params[:subject].present?
      subject_str = params[:subject].to_s
      if subject_str.downcase.include?("privat") || subject_str.downcase.include?("quotation")
        @contact_message.jenis_inkuiri = "Quotation Pelatihan Privat"
      elsif subject_str.downcase.include?("publik") || subject_str.downcase.include?("waiting list")
        @contact_message.jenis_inkuiri = "Waiting List Pelatihan Publik"
      else
        @contact_message.jenis_inkuiri = "Lainnya"
      end

      # Find matching course title
      course = Course.all.find { |c| subject_str.include?(c.title) }
      if course
        @contact_message.pelatihan = course.title
      else
        @contact_message.pelatihan = "Lainnya"
      end
    end

    @main_contact = AdminContact.find_by(main: true)
  end

  def create
    @contact_message = ContactMessage.new(contact_message_params)

    if @contact_message.save
      ContactMailer.notification(@contact_message).deliver_later
      redirect_to new_contact_path, notice: "Thanks for your message. We will get back to you soon."
    else
      @main_contact = AdminContact.find_by(main: true)
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_message_params
    params.require(:contact_message).permit(:name, :email, :company, :subject, :jenis_inkuiri, :pelatihan, :message)
  end
end
