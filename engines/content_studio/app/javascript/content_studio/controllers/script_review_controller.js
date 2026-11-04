import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["confirmWrapper"]

  connect() {
    this.approveSpans = Array.from(
      this.element.querySelectorAll('[data-scene-script-target="approveAction"]')
    )

    if (this.approveSpans.length > 0) {
      this.observer = new MutationObserver(() => this.checkAllApproved())
      this.approveSpans.forEach(span => {
        this.observer.observe(span, { attributes: true, attributeFilter: ["class"] })
      })
    }

    this.element.addEventListener("focusin", this.onFocusIn)
    this.element.addEventListener("focusout", this.onFocusOut)
  }

  disconnect() {
    this.observer?.disconnect()
    this.element.removeEventListener("focusin", this.onFocusIn)
    this.element.removeEventListener("focusout", this.onFocusOut)
  }

  onFocusIn = (e) => {
    const textarea = e.target.closest('[data-scene-script-target="textarea"]')
    if (!textarea) return
    const card = textarea.closest('[data-controller~="scene-script"]')
    document.dispatchEvent(new CustomEvent("scene:edit-entered", { detail: { source: card } }))
  }

  onFocusOut = (e) => {
    const textarea = e.target.closest('[data-scene-script-target="textarea"]')
    if (!textarea) return
    // If focus is moving to another element within the same card, don't exit edit
    const nextTextarea = e.relatedTarget?.closest('[data-scene-script-target="textarea"]')
    if (nextTextarea) return
    document.dispatchEvent(new CustomEvent("scene:edit-exited"))
  }

  checkAllApproved() {
    const allApproved = this.approveSpans.every(span => span.classList.contains("hidden"))
    this.setConfirmEnabled(allApproved)
  }

  setConfirmEnabled(enabled) {
    if (!this.hasConfirmWrapperTarget) return
    this.confirmWrapperTarget.classList.toggle("opacity-50", !enabled)
    this.confirmWrapperTarget.classList.toggle("cursor-not-allowed", !enabled)
    this.confirmWrapperTarget.classList.toggle("pointer-events-none", !enabled)
  }
}
