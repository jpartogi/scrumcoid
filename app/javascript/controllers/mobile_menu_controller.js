import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "panel", "openIcon", "closeIcon"]

  connect() {
    this.close()
  }

  toggle() {
    if (this.panelTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.panelTarget.classList.remove("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "true")
    this.buttonTarget.setAttribute("aria-label", "Tutup menu navigasi")
    this.openIconTarget.classList.add("hidden")
    this.closeIconTarget.classList.remove("hidden")
  }

  close() {
    this.panelTarget.classList.add("hidden")
    this.buttonTarget.setAttribute("aria-expanded", "false")
    this.buttonTarget.setAttribute("aria-label", "Buka menu navigasi")
    this.openIconTarget.classList.remove("hidden")
    this.closeIconTarget.classList.add("hidden")
  }
}
