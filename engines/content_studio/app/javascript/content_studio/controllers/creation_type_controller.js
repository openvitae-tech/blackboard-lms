import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['continueButton']

  select (event) {
    const card = event.target.closest('[data-url]')
    if (!card) return
    this.continueButtonTarget.href = card.dataset.url
    this.continueButtonTarget.classList.remove('pointer-events-none', 'opacity-50')
  }
}
