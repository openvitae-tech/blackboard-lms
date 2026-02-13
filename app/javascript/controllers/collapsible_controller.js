import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon"]
  static values = { open: Boolean }

  connect() {
    if (this.openValue) {
      this.open()
    } else {
      this.close()
    }
  }

  toggle() {
    this.openValue = !this.openValue
  }

  openValueChanged() {
    if (this.openValue) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.contentTarget.classList.remove("hidden")
    this.iconTarget.classList.add("rotate-180")
  }

  close() {
    this.contentTarget.classList.add("hidden")
    this.iconTarget.classList.remove("rotate-180")
  }
}