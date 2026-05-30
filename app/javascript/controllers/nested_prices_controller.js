import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rows", "template"]

  add(event) {
    event.preventDefault()

    const id = new Date().getTime()
    const content = this.templateTarget.innerHTML.replaceAll("NEW_RECORD", id)
    this.rowsTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()

    const row = event.target.closest("[data-price-row]")
    const destroyInput = row.querySelector("input[name*='[_destroy]']")

    if (destroyInput) {
      destroyInput.value = "1"
      row.classList.add("hidden")
    } else {
      row.remove()
    }
  }
}
