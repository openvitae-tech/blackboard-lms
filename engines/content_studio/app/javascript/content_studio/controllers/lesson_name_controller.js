import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "input"]
  static values = { href: String }

  connect() {
    this._clickTimer = null
  }

  click() {
    if (!this.inputTarget.classList.contains('hidden')) return

    this._clickTimer = setTimeout(() => {
      window.location.href = this.hrefValue
    }, 250)
  }

  dblclick() {
    clearTimeout(this._clickTimer)
    this._clickTimer = null
    this._startEditing()
  }

  blur() {
    this._stopEditing()
  }

  keydown(event) {
    if (event.key === 'Enter') {
      event.preventDefault()
      this._stopEditing()
    } else if (event.key === 'Escape') {
      this.inputTarget.value = this.displayTarget.textContent.trim()
      this._stopEditing()
    }
  }

  _startEditing() {
    this.inputTarget.value = this.displayTarget.textContent.trim()
    this.displayTarget.classList.add('hidden')
    this.inputTarget.classList.remove('hidden')
    this.inputTarget.focus()
    this.inputTarget.select()
  }

  _stopEditing() {
    this.displayTarget.textContent = this.inputTarget.value
    this.displayTarget.classList.remove('hidden')
    this.inputTarget.classList.add('hidden')
  }
}
