import { Controller } from "@hotwired/stimulus"

// Prevents double-clicks on file download links by disabling the link
// for a short window after the first click, then re-enabling it.
export default class extends Controller {
  static values = { cooldown: { type: Number, default: 6000 } }

  start(event) {
    if (this.#busy) {
      event.preventDefault()
      return
    }

    this.#busy = true
    this.element.classList.add("pointer-events-none", "opacity-50")

    this.#timer = setTimeout(() => this.#reset(), this.cooldownValue)
  }

  disconnect() {
    clearTimeout(this.#timer)
  }

  #busy = false
  #timer = null

  #reset() {
    this.#busy = false
    this.element.classList.remove("pointer-events-none", "opacity-50")
  }
}
