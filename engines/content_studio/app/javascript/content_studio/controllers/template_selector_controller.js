import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['card', 'radio', 'preview']

  connect() {
    const checked = this.radioTargets.find(r => r.checked)
    if (checked) this.updatePreview(checked.dataset.thumbnailUrl)
  }

  select(event) {
    const radio = event.currentTarget.querySelector('[data-template-selector-target="radio"]')
    if (!radio) return

    radio.checked = true
    const selectedIdx = this.radioTargets.indexOf(radio)

    this.cardTargets.forEach((card, i) => {
      const active = i === selectedIdx
      card.classList.toggle('border-2', active)
      card.classList.toggle('border-primary', active)
      card.classList.toggle('border', !active)
      card.classList.toggle('border-line-colour', !active)
    })

    this.updatePreview(radio.dataset.thumbnailUrl)
  }

  updatePreview(url) {
    if (!this.hasPreviewTarget) return
    this.previewTarget.src = url || ''
  }
}
