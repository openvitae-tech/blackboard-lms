import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "toggle"]
  static values = {
    clampClass: String
  }

  connect() {
    // Hide "Show more" if content does not overflow
    if (!this.isOverflowing()) {
      this.toggleTarget.classList.add("hidden")
    }
  }

  toggle() {
    this.contentTarget.classList.toggle(this.clampClassValue)

    const isClamped = this.contentTarget.classList.contains(this.clampClassValue)
    this.toggleTarget.textContent = isClamped ? "Show more" : "Show less"
  }

  isOverflowing() {
    return this.contentTarget.scrollHeight > this.contentTarget.clientHeight
  }
}
