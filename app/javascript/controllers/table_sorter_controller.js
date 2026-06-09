import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["body", "header"]

  sort(event) {
    const button = event.currentTarget
    const key = button.dataset.sortKey
    const type = button.dataset.sortType || "string"
    const currentDirection = button.dataset.direction === "asc" ? "desc" : "asc"

    this.headerTargets.forEach((header) => {
      const isActive = header === button
      header.dataset.direction = isActive ? currentDirection : ""
      header.setAttribute("aria-sort", isActive ? (currentDirection === "asc" ? "ascending" : "descending") : "none")
      this.updateSortIcons(header, isActive ? currentDirection : null)
    })

    const rows = Array.from(this.bodyTarget.querySelectorAll("tr[data-sort-row]"))
    rows.sort((leftRow, rightRow) => {
      const leftValue = leftRow.dataset[key] ?? ""
      const rightValue = rightRow.dataset[key] ?? ""

      let comparison = 0
      if (type === "number") {
        comparison = Number(leftValue) - Number(rightValue)
      } else {
        comparison = leftValue.localeCompare(rightValue, undefined, { sensitivity: "base" })
      }

      return currentDirection === "asc" ? comparison : -comparison
    })

    rows.forEach((row) => this.bodyTarget.appendChild(row))
  }

  updateSortIcons(header, direction) {
    const upIcon = header.querySelector("[data-sort-icon='up']")
    const downIcon = header.querySelector("[data-sort-icon='down']")

    if (!upIcon || !downIcon) return

    upIcon.classList.toggle("text-indigo-600", direction === "asc")
    upIcon.classList.toggle("text-slate-300", direction !== "asc")
    downIcon.classList.toggle("text-indigo-600", direction === "desc")
    downIcon.classList.toggle("text-slate-300", direction !== "desc")
  }
}