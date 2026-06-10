import { Controller } from "@hotwired/stimulus"

const POLL_INTERVAL_MS = 5000

export default class extends Controller {
  static values = {
    pending: Boolean,
    thumbnailUrl: { type: String, default: '' }
  }

  connect() {
    if (this.pendingValue) {
      this.timer = setTimeout(() => {
        this.element.closest('turbo-frame').src = window.location.href
      }, POLL_INTERVAL_MS)
    }
  }

  disconnect() {
    clearTimeout(this.timer)
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
}
