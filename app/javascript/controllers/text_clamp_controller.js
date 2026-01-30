import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["longText", "showMoretoggle"]
  static values = {
    css: String
  }

  connect() {
    this.showMoretoggleTargets.forEach((showMoretoggle, idx) => {
      if (!this.isOverflowing(idx)) {
        showMoretoggle.classList.add("hidden")
      }
    })
  }

  showMoretoggle(event) {
    const clickedIndex = this.showMoretoggleTargets.indexOf(event.currentTarget)
    const longTextTarget = this.longTextTargets[clickedIndex]
    longTextTarget.classList.toggle(this.cssValue)
    const isClamped = longTextTarget.classList.contains(this.cssValue)
    event.currentTarget.textContent = isClamped ? "Show more" : "Show less"
  }

  isOverflowing(idx) {
    const longTextTarget = this.longTextTargets[idx]
    return longTextTarget.scrollHeight > longTextTarget.clientHeight
  }
}
