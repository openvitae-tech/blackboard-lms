import { Controller } from "@hotwired/stimulus"

const POLL_INTERVAL_MS = 5000

export default class extends Controller {
  static values = {
    pending: Boolean
  }

  connect() {
    if (this.pendingValue) {
      this.timer = setTimeout(() => {
        this.element.closest('turbo-frame').src = window.location.href
      }, POLL_INTERVAL_MS)
    }
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
