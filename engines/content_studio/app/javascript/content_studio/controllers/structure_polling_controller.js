import { Controller } from "@hotwired/stimulus"

const POLL_INTERVAL_MS = 5000

export default class extends Controller {
  static values = {
    pending: Boolean,
    thumbnailUrl: { type: String, default: '' }
  }

  connect() {
    this._dragging = false
    this._onDragStart = () => {
      this._dragging = true
      clearTimeout(this.timer)
    }
    this._onDragEnd = () => {
      this._dragging = false
      this._schedulePoll()
    }
    this._onFrameLoad = () => {
      this._applyThumbnail()
      this._schedulePoll()
    }
    this._onBeforeVisit = () => clearTimeout(this.timer)
    window.addEventListener('module-select:drag-start', this._onDragStart)
    window.addEventListener('module-select:drag-end', this._onDragEnd)
    document.addEventListener('turbo:before-visit', this._onBeforeVisit)
    this._frame = this.element.closest('turbo-frame')
    this._frame?.addEventListener('turbo:frame-load', this._onFrameLoad)
    this._schedulePoll()
  }

  disconnect() {
    clearTimeout(this.timer)
    window.removeEventListener('module-select:drag-start', this._onDragStart)
    window.removeEventListener('module-select:drag-end', this._onDragEnd)
    document.removeEventListener('turbo:before-visit', this._onBeforeVisit)
    this._frame?.removeEventListener('turbo:frame-load', this._onFrameLoad)
  }

  thumbnailUrlValueChanged(url) {
    this._applyThumbnail()
  }

  _applyThumbnail() {
    const url = this.thumbnailUrlValue
    if (!url) return
    const img = document.getElementById('course-thumbnail-img')
    if (!img || img.dataset.loadedUrl === url) return
    img.src = url
    img.classList.replace('object-contain', 'object-cover')
    img.dataset.loadedUrl = url
  }

  _schedulePoll() {
    clearTimeout(this.timer)
    if (!this.pendingValue || this._dragging || !this._frame) return
    this.timer = setTimeout(() => {
      this._frame.src = window.location.href
    }, POLL_INTERVAL_MS)
  }
}
