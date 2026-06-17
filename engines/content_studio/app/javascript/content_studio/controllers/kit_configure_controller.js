import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['submit', 'checkbox']

  connect() {
    this.updateSubmit()
  }

  onCheckboxChanged() {
    this.updateSubmit()
  }

  updateSubmit() {
    const anyChecked = this.checkboxTargets.some(cb => cb.checked)

    this.submitTarget.disabled = !anyChecked

    const inner = this.submitTarget.querySelector('[class*="btn-"]')
    if (inner) {
      inner.classList.toggle('btn-disabled', !anyChecked)
      inner.classList.toggle('btn-solid-primary-disabled', !anyChecked)
    }
  }
}
