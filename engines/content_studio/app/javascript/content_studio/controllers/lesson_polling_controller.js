import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { pending: Boolean }

  connect() {
    if (this.pendingValue) {
      this.timer = setTimeout(() => {
        this.element.closest('turbo-frame').src = window.location.href
      }, 5000)
    }
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}
