import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.timeout = null
  }

  disconnect() {
    clearTimeout(this.timeout)
    this.timeout = null
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
}
