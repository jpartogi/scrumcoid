import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["title", "slug"]
  static values = {
    auto: { type: Boolean, default: true }
  }

  connect() {
    this.slugManuallyEdited = !this.autoValue
  }

  generateSlug() {
    if (this.slugManuallyEdited) return

    this.slugTarget.value = this.parameterize(this.titleTarget.value)
  }

  markSlugManual() {
    this.slugManuallyEdited = true
  }

  parameterize(value) {
    return value
      .toString()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .toLowerCase()
      .trim()
      .replace(/[^a-z0-9\s-]/g, "")
      .replace(/\s+/g, "-")
      .replace(/-+/g, "-")
      .replace(/^-|-$/g, "")
  }
}