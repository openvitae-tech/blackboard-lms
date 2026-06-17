import { Controller } from "@hotwired/stimulus"

const POLL_INTERVAL_MS = 5000

export default class extends Controller {
  static values = { pending: Boolean }

  connect() {
    this._onFrameLoad = () => this._schedulePoll()
    this._onBeforeVisit = () => clearTimeout(this.timer)
    document.addEventListener('turbo:before-visit', this._onBeforeVisit)
    this._frame = this.element.closest('turbo-frame')
    this._frame?.addEventListener('turbo:frame-load', this._onFrameLoad)
    this._schedulePoll()
  }

  disconnect() {
    clearTimeout(this.timer)
    document.removeEventListener('turbo:before-visit', this._onBeforeVisit)
    this._frame?.removeEventListener('turbo:frame-load', this._onFrameLoad)
  }

  _schedulePoll() {
    clearTimeout(this.timer)
    if (!this.pendingValue || !this._frame) return
    this.timer = setTimeout(() => {
      this._frame.src = window.location.href
    }, POLL_INTERVAL_MS)
  }
}
