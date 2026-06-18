import { Controller } from "@hotwired/stimulus"

const POLL_INTERVAL_MS = 5000

const BANNER_HIDE_DELAY_MS = 1500

export default class extends Controller {
  static values = {
    pending: Boolean,
    thumbnailUrl: { type: String, default: '' }
  }

  static targets = ['banner']

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
    this._onFrameMissing = (event) => { event.preventDefault(); this._schedulePoll() }
    window.addEventListener('module-select:drag-start', this._onDragStart)
    window.addEventListener('module-select:drag-end', this._onDragEnd)
    document.addEventListener('turbo:before-visit', this._onBeforeVisit)
    this._frame = this.element.closest('turbo-frame')
    this._frame?.addEventListener('turbo:frame-load', this._onFrameLoad)
    this._frame?.addEventListener('turbo:frame-missing', this._onFrameMissing)
    this._schedulePoll()
  }

  disconnect() {
    clearTimeout(this.timer)
    window.removeEventListener('module-select:drag-start', this._onDragStart)
    window.removeEventListener('module-select:drag-end', this._onDragEnd)
    document.removeEventListener('turbo:before-visit', this._onBeforeVisit)
    this._frame?.removeEventListener('turbo:frame-load', this._onFrameLoad)
    this._frame?.removeEventListener('turbo:frame-missing', this._onFrameMissing)
  }

  pendingValueChanged(pending) {
    if (pending || !this.hasBannerTarget) return
    setTimeout(() => {
      this.bannerTarget.style.visibility = 'hidden'
    }, BANNER_HIDE_DELAY_MS)
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
