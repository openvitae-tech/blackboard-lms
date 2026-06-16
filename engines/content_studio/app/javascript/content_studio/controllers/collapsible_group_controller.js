import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["collapseBtn", "expandBtn"]

  connect() {
    this._onChanged = () => this.updateButtonState()
    this.element.addEventListener('collapsible:changed', this._onChanged)
    // Defer so all child collapsible controllers have connected and applied their state first.
    setTimeout(() => this.updateButtonState(), 0)
  }

  disconnect() {
    this.element.removeEventListener('collapsible:changed', this._onChanged)
  }

  collapseAll() {
    window.dispatchEvent(new CustomEvent('collapsible:close-all'))
  }

  expandAll() {
    window.dispatchEvent(new CustomEvent('collapsible:open-all'))
  }

  updateButtonState() {
    const contents = this.element.querySelectorAll('[data-collapsible-target="content"]')
    if (contents.length === 0) return
    const allCollapsed = [...contents].every(el => el.classList.contains('hidden'))
    this.collapseBtnTarget.classList.toggle('hidden', allCollapsed)
    this.expandBtnTarget.classList.toggle('hidden', !allCollapsed)
  }
}
