import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    start: String,
    end: String,
    format: { type: String, default: "datetime" },
    prefix: { type: String, default: "" }
  }

  connect() {
    const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone
    const start = new Date(this.startValue)
    const end = this.hasEndValue ? new Date(this.endValue) : null

    if (Number.isNaN(start.getTime()) || (end && Number.isNaN(end.getTime()))) return

    const formatted = this.formatValue === "range" && end
      ? this.formatRange(start, end, timeZone)
      : this.formatDateTime(start, timeZone)

    this.element.textContent = `${this.prefixValue}${formatted}`
    this.element.title = `Shown in your local timezone (${timeZone})`
  }

  formatDateTime(date, timeZone) {
    return new Intl.DateTimeFormat(undefined, {
      year: "numeric",
      month: "short",
      day: "numeric",
      hour: "numeric",
      minute: "2-digit",
      timeZone,
      timeZoneName: "short"
    }).format(date)
  }

  formatRange(start, end, timeZone) {
    const dateFormatter = new Intl.DateTimeFormat(undefined, {
      dateStyle: "medium",
      timeZone
    })
    const timeFormatter = new Intl.DateTimeFormat(undefined, {
      hour: "numeric",
      minute: "2-digit",
      timeZone,
      timeZoneName: "short"
    })

    const startDate = dateFormatter.format(start)
    const endDate = dateFormatter.format(end)
    const startTime = timeFormatter.format(start)
    const endTime = timeFormatter.format(end)

    if (startDate === endDate) {
      return `${startDate}, ${startTime} - ${endTime}`
    }

    return `${startDate}, ${startTime} - ${endDate}, ${endTime}`
  }
}
