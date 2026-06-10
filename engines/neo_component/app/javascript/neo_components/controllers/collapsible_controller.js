import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "icon", "expandLink"]
  static values = { open: Boolean, storageKey: { type: String, default: '' } }

  // initialize() fires before openValueChanged and before connect(),
  // so setting _restoring here guarantees the initial openValueChanged call never saves.
  initialize() {
    this._restoring = true
  }

  connect() {
    if (this.storageKeyValue) {
      const saved = sessionStorage.getItem(this.storageKeyValue)
      if (saved !== null) this.openValue = saved === 'true'
    }
    this._restoring = false
  }

  toggle(event) {
    if (event.target.closest("a, button")) return
    this.openValue = !this.openValue
  }

  expand(event) {
    event.preventDefault()
    this.openValue = true
  }

  // Called by the global collapse-all/expand-all window events.
  // Goes through openValue so sessionStorage is updated.
  closeFromGlobal() {
    this.openValue = false
  }

  openFromGlobal() {
    this.openValue = true
  }

  openValueChanged() {
    if (!this._restoring && this.storageKeyValue) {
      sessionStorage.setItem(this.storageKeyValue, this.openValue)
    }
    if (this.openValue) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.contentTarget.classList.remove("hidden")
    this.iconTarget.classList.add("rotate-180")
    if (this.hasExpandLinkTarget) this.expandLinkTarget.classList.add("hidden")
    this.element.dispatchEvent(new CustomEvent('collapsible:changed', { bubbles: true }))
  }

  close() {
    this.contentTarget.classList.add("hidden")
    this.iconTarget.classList.remove("rotate-180")
    if (this.hasExpandLinkTarget) this.expandLinkTarget.classList.remove("hidden")
    this.element.dispatchEvent(new CustomEvent('collapsible:changed', { bubbles: true }))
  }
}
