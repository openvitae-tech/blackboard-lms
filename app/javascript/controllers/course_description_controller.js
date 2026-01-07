import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["courseDescription", "showMoretoggle"]
  static values = {
    clampClass: String
  }

  connect() {
    if (!this.isOverflowing()) {
      this.showMoretoggleTarget.classList.add("hidden")
    }
  }

  showMoretoggle() {
    this.courseDescriptionTarget.classList.toggle(this.clampClassValue)
    const isClamped = this.courseDescriptionTarget.classList.contains(this.clampClassValue)
    this.showMoretoggleTarget.textContent = isClamped ? "Show more" : "Show less"
  }

  isOverflowing() {
    return this.courseDescriptionTarget.scrollHeight > this.courseDescriptionTarget.clientHeight
  }
}
