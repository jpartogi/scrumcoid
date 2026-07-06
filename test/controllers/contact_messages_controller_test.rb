require "test_helper"

class ContactMessagesControllerTest < ActionDispatch::IntegrationTest
  test "shows contact form and displays main WhatsApp contact when present" do
    AdminContact.destroy_all
    main_contact = AdminContact.create!(email: "main@example.com", name: "Joko", whatsapp_number: "+62812345", main: true)

    get new_contact_path

    assert_response :success
    assert_select "h1", /Diskusikan Kebutuhan/
    assert_select "strong", "Joko"
    assert_select "a[href=?]", "https://wa.me/62812345"
  end

  test "creates contact message" do
    assert_difference -> { ContactMessage.count }, 1 do
      post contact_path, params: {
        contact_message: {
          name: "Pat Customer",
          email: "pat@example.com",
          company: "Customer Co",
          subject: "Training enquiry",
          message: "Can we discuss a private class?"
        }
      }
    end

    assert_redirected_to new_contact_path
    assert ContactMessage.last.unread?
  end

  test "creates contact message with dropdown choices and compiles subject" do
    assert_difference -> { ContactMessage.count }, 1 do
      post contact_path, params: {
        contact_message: {
          name: "Susi",
          email: "susi@example.com",
          company: "Susi Corp",
          jenis_inkuiri: "Quotation Pelatihan Privat",
          pelatihan: "Scrum.org AI Essentials",
          message: "Saya tertarik dengan pelatihan privat AI Essentials."
        }
      }
    end

    assert_redirected_to new_contact_path
    last_message = ContactMessage.last
    assert_equal "Quotation Pelatihan Privat - Scrum.org AI Essentials", last_message.subject
    assert last_message.unread?
  end

  test "new action pre-fills form fields based on query parameters" do
    get new_contact_path(jenis_inkuiri: "Pendaftaran Grup", pelatihan: "Scrum.org AI Essentials")

    assert_response :success
    assert_select "select#contact_message_jenis_inkuiri" do
      assert_select "option[selected]", text: "Pendaftaran Grup"
    end
    assert_select "select#contact_message_pelatihan" do
      assert_select "option[selected]", text: "Scrum.org AI Essentials"
    end
  end

  test "rejects submission when honeypot field is filled" do
    assert_no_difference -> { ContactMessage.count } do
      assert_no_enqueued_emails do
        post contact_path, params: {
          contact_message: {
            name: "Spam Bot",
            email: "spam@example.com",
            company: "Spam Inc",
            subject: "Buy now",
            message: "Click this link",
            website: "https://spam.example"
          }
        }
      end
    end

    assert_redirected_to new_contact_path
    assert_equal "Terima kasih atas pesan Anda. Kami akan segera menghubungi Anda kembali.", flash[:notice]
  end

  test "creates contact message when honeypot field is left empty" do
    assert_difference -> { ContactMessage.count }, 1 do
      assert_enqueued_emails 1 do
        post contact_path, params: {
          contact_message: {
            name: "Pat Customer",
            email: "pat@example.com",
            company: "Customer Co",
            subject: "Training enquiry",
            message: "Can we discuss a private class?",
            website: ""
          }
        }
      end
    end

    assert_redirected_to new_contact_path
  end

  test "new action parses fallback subject query param correctly" do
    get new_contact_path(subject: "Pendaftaran Grup: Scrum.org AI Essentials")

    assert_response :success
    assert_select "select#contact_message_jenis_inkuiri" do
      assert_select "option[selected]", text: "Pendaftaran Grup"
    end
    assert_select "select#contact_message_pelatihan" do
      assert_select "option[selected]", text: "Scrum.org AI Essentials"
    end
  end
end
