import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['submit']
  static values = {
    existingCount: { type: Number, default: 0 }
  }

  connect() {
    this.browserCount = 0
    this.submitTarget.disabled = this.existingCountValue === 0
  }

  onFilesChanged(event) {
    this.browserCount = event.detail.count
    this.updateSubmit()
  }

  removeExisting(event) {
    const item = event.currentTarget.closest('.file-selector-list-item')
    const input = document.createElement('input')
    input.type = 'hidden'
    input.name = 'removed_files[]'
    input.value = item.dataset.url
    this.element.appendChild(input)
    item.remove()
    this.existingCountValue--
    this.updateSubmit()
  }

  updateSubmit() {
    this.submitTarget.disabled = this.existingCountValue + this.browserCount === 0
  }
}
