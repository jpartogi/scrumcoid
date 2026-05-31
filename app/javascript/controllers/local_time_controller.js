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
    const opts = { timeZone }

    const startDay = start.toLocaleString('en-US', { ...opts, day: 'numeric' })
    const endDay = end.toLocaleString('en-US', { ...opts, day: 'numeric' })
    const startMonth = start.toLocaleString('en-US', { ...opts, month: 'long' })
    const endMonth = end.toLocaleString('en-US', { ...opts, month: 'long' })
    const year = start.toLocaleString('en-US', { ...opts, year: 'numeric' })

    const timeFormatter = new Intl.DateTimeFormat('en-US', {
      hour: 'numeric',
      minute: '2-digit',
      hour12: true,
      timeZone
    })

    const startTime = timeFormatter.format(start)
    const endTime = timeFormatter.format(end)

    const startMonthNum = parseInt(start.toLocaleString('en-US', { ...opts, month: 'numeric' }))
    const endMonthNum = parseInt(end.toLocaleString('en-US', { ...opts, month: 'numeric' }))
    const startYear = parseInt(start.toLocaleString('en-US', { ...opts, year: 'numeric' }))
    const endYear = parseInt(end.toLocaleString('en-US', { ...opts, year: 'numeric' }))

    const sameDay = startDay === endDay && startMonthNum === endMonthNum && startYear === endYear

    if (sameDay) {
      return `${startDay} ${startMonth} ${year} ${startTime} - ${endTime}`
    }

    if (startMonthNum === endMonthNum && startYear === endYear) {
      // Same month
      return `${startDay} - ${endDay} ${startMonth} ${year} ${startTime} - ${endTime}`
    }

    // Different months
    return `${startDay} ${startMonth} - ${endDay} ${endMonth} ${year} ${startTime} - ${endTime}`
  }
}
