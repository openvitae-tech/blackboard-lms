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
    window.addEventListener('module-select:drag-start', this._onDragStart)
    window.addEventListener('module-select:drag-end', this._onDragEnd)
    this._schedulePoll()
  }

  disconnect() {
    clearTimeout(this.timer)
    window.removeEventListener('module-select:drag-start', this._onDragStart)
    window.removeEventListener('module-select:drag-end', this._onDragEnd)
  }

  // Updates the permanent thumbnail img only when the URL first becomes available.
  // The loadedUrl guard prevents redundant updates (and re-fetches) on subsequent polls.
  thumbnailUrlValueChanged(url) {
    if (!url) return
    const img = document.getElementById('course-thumbnail-img')
    if (!img || img.dataset.loadedUrl === url) return
    img.src = url
    img.classList.replace('object-contain', 'object-cover')
    img.dataset.loadedUrl = url
  }

  _schedulePoll() {
    clearTimeout(this.timer)
    if (!this.pendingValue || this._dragging) return
    this.timer = setTimeout(() => {
      this.element.closest('turbo-frame').src = window.location.href
    }, POLL_INTERVAL_MS)
  }
}
