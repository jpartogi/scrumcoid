import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["participants", "template", "financeName", "financeEmail", "sameAsBilling"]

  add(event) {
    event.preventDefault()
    
    const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, new Date().getTime())
    this.participantsTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()
    
    const wrapper = event.target.closest("[data-participant-wrapper]")
    if (wrapper) {
      const destroyInput = wrapper.querySelector("input[name*='_destroy']")
      if (destroyInput) {
        destroyInput.value = "1"
        wrapper.style.display = "none"
      } else {
        wrapper.remove()
      }
    }
  }

  toggleSameAsBilling(event) {
    if (event.target.checked) {
      this.syncSameAsBilling()
    } else {
      const firstWrapper = this.participantsTarget.querySelector("[data-participant-wrapper]")
      if (firstWrapper) {
        const emailInput = firstWrapper.querySelector("input[name*='[email]']")
        if (emailInput) emailInput.value = ""
      }
    }
  }

  syncSameAsBilling() {
    if (this.hasSameAsBillingTarget && this.sameAsBillingTarget.checked) {
      const emailVal = this.hasFinanceEmailTarget ? this.financeEmailTarget.value : ""

      const firstWrapper = this.participantsTarget.querySelector("[data-participant-wrapper]")
      if (firstWrapper) {
        const emailInput = firstWrapper.querySelector("input[name*='[email]']")
        if (emailInput) emailInput.value = emailVal
      }
    }
  }
}