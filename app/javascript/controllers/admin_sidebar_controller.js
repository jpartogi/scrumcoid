import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "admin-sidebar-collapsed"

export default class extends Controller {
  static targets = ["sidebar", "main"]

  connect() {
    console.log("Admin sidebar controller connected");
    if (localStorage.getItem(STORAGE_KEY) === "true") {
      this.collapse(false)
    }
  }

  toggle() {
    if (this.isCollapsed()) {
      this.expand()
    } else {
      this.collapse()
    }
  }

  collapse(persist = true) {
    this.sidebarTarget.classList.add("collapsed")
    this.mainTarget.classList.remove("ml-64")
    this.mainTarget.classList.add("ml-20")
    if (persist) localStorage.setItem(STORAGE_KEY, "true")
  }

  expand() {
    this.sidebarTarget.classList.remove("collapsed")
    this.mainTarget.classList.add("ml-64")
    this.mainTarget.classList.remove("ml-20")
    localStorage.setItem(STORAGE_KEY, "false")
  }

  isCollapsed() {
    return this.sidebarTarget.classList.contains("collapsed")
  }
}