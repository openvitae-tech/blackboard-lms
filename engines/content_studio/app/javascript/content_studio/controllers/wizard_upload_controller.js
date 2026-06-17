import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['submit', 'title']
  static values = {
    existingCount: { type: Number, default: 0 }
  }

  connect() {
    this.browserCount = 0
    this.updateSubmit()
  }

  onFilesChanged(event) {
    this.browserCount = event.detail.count
    this.updateSubmit()
  }

  onTitleChanged() {
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
    const hasTitle = this.hasTitleTarget ? this.titleTarget.value.trim().length > 0 : true
    const hasFiles = this.existingCountValue + this.browserCount > 0
    const enabled = hasTitle && hasFiles

    this.submitTarget.disabled = !enabled

    // Apply/remove disabled visual styles on the inner button_component div
    const inner = this.submitTarget.querySelector('[class*="btn-"]')
    if (inner) {
      inner.classList.toggle('btn-disabled', !enabled)
      inner.classList.toggle('btn-solid-primary-disabled', !enabled)
    }
  }
}
