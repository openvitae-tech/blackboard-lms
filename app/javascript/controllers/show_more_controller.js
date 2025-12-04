import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "button"]

  connect() {
    this.collectHeightClasses()

    if (this.contentTarget.scrollHeight > this.contentTarget.clientHeight) {
      this.buttonTarget.classList.remove("hidden")
    }
  }

  collectHeightClasses() {
    this.heightClasses = Array.from(this.contentTarget.classList).filter(cls =>
      cls.match(/(^h-\[?.*\]?$)|(^max-h-\[?.*\]?$)|(.*:h-\[?.*\]?$)|(.*:max-h-\[?.*\]?$)/)
    )
  }

  toggle() {
    const expanded = this.contentTarget.dataset.expanded === "true"

    if (expanded) {
      for (const cls of this.heightClasses) {
        this.contentTarget.classList.add(cls)
      }
      this.buttonTarget.innerText = "Show more"
      this.contentTarget.dataset.expanded = "false"
    } else {
      for (const cls of this.heightClasses) {
        this.contentTarget.classList.remove(cls)
      }
      this.buttonTarget.innerText = "Show less"
      this.contentTarget.dataset.expanded = "true"
    }
  }
}
