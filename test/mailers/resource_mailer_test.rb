require "test_helper"

class ResourceMailerTest < ActionMailer::TestCase
  test "download_link includes resource title and download url" do
    download_request = resource_download_requests(:pending_download)
    mail = ResourceMailer.download_link(download_request)

    assert_equal [download_request.visitor_email], mail.to
    assert_match download_request.resource.title, mail.subject
    assert_match "/resource-downloads/#{download_request.token}", mail.body.encoded
    
    # Assert presence of new content
    assert_match "Kalau ada pertanyaan lebih lanjut jangan sungkan untuk menghubungi saya", mail.body.encoded
    assert_match "856 4342 8348", mail.body.encoded
    assert_match "scrum.co.id", mail.body.encoded
  end
end