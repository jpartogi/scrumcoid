require "test_helper"

class ResourcesControllerTest < ActionDispatch::IntegrationTest
  test "index lists published resources" do
    get resources_path
    assert_response :success
    assert_match resources(:published_resource).title, response.body
    assert_match resources(:free_resource).title, response.body
    assert_no_match resources(:draft_resource).title, response.body
  end

  test "index shows Resources menu in navbar" do
    get resources_path
    assert_response :success
    assert_select "a[href=?]", resources_path, text: /Resources/
  end

  test "index filters by tag" do
    get resources_path(tag: "scrum")
    assert_response :success
    assert_match resources(:published_resource).title, response.body
    assert_no_match resources(:free_resource).title, response.body
  end

  test "index renders tag filter pills in hero" do
    get resources_path
    assert_response :success
    assert_select "section.bg-slate-950 a[href=?]", resources_path(tag: "scrum"), text: /scrum/
    assert_select "section.bg-slate-950 a[href=?]", resources_path, text: /Semua/
  end

  test "index renders horizontal cards with portrait thumbnails" do
    get resources_path
    assert_response :success
    assert_match "aspect-[3/4]", response.body
    assert_select "article.flex"
  end

  test "index shows direct download link for free resources with file" do
    resource = resources(:free_resource)
    attach_sample_file(resource)

    get resources_path
    assert_response :success
    assert_select "a[href=?]", new_resource_download_request_path(resource), text: /Download/
  end

  test "show displays email download button for free resources with file" do
    resource = resources(:free_resource)
    attach_sample_file(resource)

    get resource_path(resource)
    assert_response :success
    assert_select "a[href=?]", new_resource_download_request_path(resource), text: /Dapatkan lewat Email/
    assert_match "Jessica Stella", response.body
    assert_match "+62 856 4342 8348", response.body
    assert_select "a[href='https://wa.me/6285643428348']", text: /Chat Jessica via WhatsApp/
  end

  test "show displays published resource with meta keywords" do
    resource = resources(:published_resource)
    get resource_path(resource)
    assert_response :success
    assert_select "meta[name='keywords'][content='scrum, agile, cheat sheet']"
    assert_match resource.display_price, response.body
  end

  test "show renders portrait thumbnail in hero" do
    resource = resources(:free_resource)
    record = Resource.find(resource.id)
    unless record.thumbnail.attached?
      record.thumbnail.attach(
        io: file_fixture("course-logo.png").open,
        filename: "thumbnail.png",
        content_type: "image/png"
      )
    end

    get resource_path(resource)
    assert_response :success
    assert_select "section.bg-slate-950 .aspect-\\[9\\/16\\] img[alt='#{resource.title}']"
  end

  test "show does not display draft resource" do
    get resource_path(resources(:draft_resource))
    assert_response :not_found
  end

  test "homepage navbar includes Resources between Tentang and Blog" do
    get root_path
    assert_response :success
    body = response.body
    tentang_index = body.index("Tentang")
    resources_index = body.index(">Resources<") || body.index("Resources</")
    blog_index = body.index(">Blog<") || body.index("Blog</")
    assert tentang_index, "Expected Tentang in navbar"
    assert resources_index, "Expected Resources in navbar"
    assert blog_index, "Expected Blog in navbar"
    assert tentang_index < resources_index
    assert resources_index < blog_index
  end

  private

  def attach_sample_file(resource)
    record = Resource.find(resource.id)
    return if record.file_attachment.attached?

    record.file_attachment.attach(
      io: file_fixture("sample-resource.pdf").open,
      filename: "sample-resource.pdf",
      content_type: "application/pdf"
    )
  end
end