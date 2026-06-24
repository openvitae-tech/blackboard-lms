import { Controller } from "@hotwired/stimulus"

const POLL_INTERVAL_MS = 5000

export default class extends Controller {
  static values = {
    pending: Boolean,
    showProgress: { type: Boolean, default: true },
    thumbnailUrl: { type: String, default: '' }
  }

  static targets = ['banner']

  connect() {
    this._startedPending = this.pendingValue
    this._storageKey = `kit-was-pending-${window.location.pathname}`

    if (this.hasBannerTarget) {
      if (!this.showProgressValue) {
        this.bannerTarget.style.display = 'none'
      } else if (this._startedPending) {
        sessionStorage.setItem(this._storageKey, '1')
      } else if (sessionStorage.getItem(this._storageKey)) {
        // Frame reloaded after reaching 100% — show for 1 second then hide
        sessionStorage.removeItem(this._storageKey)
        this.bannerTarget.style.display = ''
        setTimeout(() => { this.bannerTarget.style.display = 'none' }, 1000)
      } else {
        this.bannerTarget.style.display = 'none'
      }
    }
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

  pendingValueChanged(pending, previousPending) {
    if (pending || previousPending === undefined || !this.hasBannerTarget) return
    if (!this._startedPending || !this.showProgressValue) return
    // Just reached 100% — show banner then hide after 1 second
    this.bannerTarget.style.display = ''
    setTimeout(() => { this.bannerTarget.style.display = 'none' }, 1000)
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
