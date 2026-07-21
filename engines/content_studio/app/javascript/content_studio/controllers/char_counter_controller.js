import { Controller } from "@hotwired/stimulus"

// Updates a character count display as the user types in a textarea.
export default class extends Controller {
  static targets = ['input', 'count']

  connect() {
    this.update()
  }

  update() {
    const len = this.hasInputTarget ? this.inputTarget.value.length : 0
    if (this.hasCountTarget) this.countTarget.textContent = len
  }
}
