import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['text', 'toggle']

  toggle(event) {
    event.preventDefault()
    const expanded = this.textTarget.classList.toggle('line-clamp-6')
    if (this.hasToggleTarget) {
      this.toggleTarget.textContent = expanded ? 'Show more' : 'Show less'
    }
  }
}
