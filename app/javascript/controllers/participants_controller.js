import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["participants", "template"]

  add(event) {
    event.preventDefault()
    
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.participantsTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()
    
    const wrapper = event.target.closest("[data-participant-wrapper]")
    if (wrapper) {
      // If it has an ID, we need to mark for destroy
      const destroyInput = wrapper.querySelector("input[name*='_destroy']")
      if (destroyInput) {
        destroyInput.value = "1"
        wrapper.style.display = "none"
      } else {
        wrapper.remove()
      }
    }
  }
}
