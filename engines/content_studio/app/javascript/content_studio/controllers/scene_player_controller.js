import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'video', 'placeholder', 'narration', 'item', 'regenerateButton',
    'prevButton', 'nextButton',
    'playIcon', 'pauseIcon',
    'progressTrack', 'progressFill', 'currentTime', 'duration', 'controlBar'
  ]
  static values = {
    currentIndex: { type: Number, default: 0 }
  }

  connect() {
    if (this.itemTargets.length > 0) {
      this.loadScene(0)
    }
    this.element.addEventListener('scene-video-ready', this.onSceneVideoReady)
  }

  disconnect() {
    this.element.removeEventListener('scene-video-ready', this.onSceneVideoReady)
  }

  onSceneVideoReady = (event) => {
    const item = event.target
    const index = parseInt(item.dataset.sceneIndex, 10)
    if (index !== this.currentIndexValue) return

    const videoUrl = item.dataset.videoUrl
    if (!videoUrl || !this.hasVideoTarget) return

    this.videoTarget.src = videoUrl
    this.videoTarget.classList.remove('hidden')
    if (this.hasPlaceholderTarget) this.placeholderTarget.classList.add('hidden')
    if (this.hasControlBarTarget) this.controlBarTarget.classList.remove('hidden')
    this.updateRegenerateButton()
  }

  select(event) {
    const index = parseInt(event.currentTarget.dataset.sceneIndex, 10)
    this.loadScene(index)
    if (this.hasVideoTarget && this.videoTarget.src) {
      this.videoTarget.play().catch(() => {})
    }
  }

  prev() {
    this.loadScene(this.currentIndexValue - 1)
  }

  next() {
    this.loadScene(this.currentIndexValue + 1)
  }

  togglePlay() {
    if (!this.hasVideoTarget || !this.videoTarget.src) return
    this.videoTarget.paused ? this.videoTarget.play() : this.videoTarget.pause()
  }

  onPlay() {
    if (this.hasPlayIconTarget) this.playIconTarget.classList.add('hidden')
    if (this.hasPauseIconTarget) this.pauseIconTarget.classList.remove('hidden')
    if (this.hasControlBarTarget) this.controlBarTarget.classList.add('opacity-0')
  }

  onPause() {
    if (this.hasPlayIconTarget) this.playIconTarget.classList.remove('hidden')
    if (this.hasPauseIconTarget) this.pauseIconTarget.classList.add('hidden')
    if (this.hasControlBarTarget) this.controlBarTarget.classList.remove('opacity-0')
  }

  seek(event) {
    if (!this.hasVideoTarget || !this.videoTarget.duration) return
    const rect = this.progressTrackTarget.getBoundingClientRect()
    const ratio = Math.max(0, Math.min(1, (event.clientX - rect.left) / rect.width))
    this.videoTarget.currentTime = ratio * this.videoTarget.duration
  }

  timeUpdate() {
    if (!this.hasVideoTarget) return
    const { currentTime, duration } = this.videoTarget
    if (this.hasCurrentTimeTarget) this.currentTimeTarget.textContent = this.formatTime(currentTime)
    if (this.hasProgressFillTarget && duration) {
      this.progressFillTarget.style.width = `${(currentTime / duration) * 100}%`
    }
  }

  metadataLoaded() {
    if (!this.hasVideoTarget || !this.hasDurationTarget) return
    this.durationTarget.textContent = this.formatTime(this.videoTarget.duration)
  }

  formatTime(seconds) {
    if (!seconds || isNaN(seconds)) return '0:00'
    const m = Math.floor(seconds / 60)
    const s = Math.floor(seconds % 60).toString().padStart(2, '0')
    return `${m}:${s}`
  }

  ended() {
    const nextIndex = this.currentIndexValue + 1
    if (nextIndex < this.itemTargets.length) {
      this.loadScene(nextIndex)
      if (this.hasVideoTarget && this.videoTarget.src) {
        this.videoTarget.play().catch(() => {})
      }
    }
  }

  async regenerate() {
    if (this._regenerating) return
    this._regenerating = true

    const item = this.itemTargets[this.currentIndexValue]
    if (!item || item.dataset.sceneStatus !== 'COMPLETED') { this._regenerating = false; return }

    const url = item.dataset.regenerateUrl
    const narration = this.hasNarrationTarget ? this.narrationTarget.value : ''

    this.setRegenerateDisabled(true)

    try {
      await fetch(url, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content ?? ''
        },
        body: JSON.stringify({ narration })
      })
    } finally {
      this._regenerating = false
      this.updateRegenerateButton()
    }
  }

  onNarrationInput() {
    this.updateRegenerateButton()
  }

  loadScene(index) {
    const items = this.itemTargets
    if (index < 0 || index >= items.length) return

    items.forEach((item, i) => {
      const active = i === index
      item.classList.toggle('border-2', active)
      item.classList.toggle('border-primary-light', active)
    })

    items[index].scrollIntoView({ behavior: 'smooth', block: 'nearest' })

    const item = items[index]
    const videoUrl = item.dataset.videoUrl
    const narration = item.dataset.narration || ''

    this._originalNarration = narration

    if (this.hasNarrationTarget) {
      const el = this.narrationTarget
      el.value = narration
      el.textContent = narration
    }

    if (this.hasVideoTarget && this.hasPlaceholderTarget) {
      if (videoUrl) {
        this.videoTarget.src = videoUrl
        this.videoTarget.classList.remove('hidden')
        this.placeholderTarget.classList.add('hidden')
        if (this.hasControlBarTarget) this.controlBarTarget.classList.remove('hidden')
      } else {
        this.videoTarget.src = ''
        this.videoTarget.classList.add('hidden')
        this.placeholderTarget.classList.remove('hidden')
        if (this.hasControlBarTarget) this.controlBarTarget.classList.add('hidden')
      }
    }

    this.onPause()
    if (this.hasProgressFillTarget) this.progressFillTarget.style.width = '0%'
    if (this.hasCurrentTimeTarget) this.currentTimeTarget.textContent = '0:00'
    if (this.hasDurationTarget) this.durationTarget.textContent = '0:00'

    this.currentIndexValue = index
    this.updateNavButtons()
    this.updateRegenerateButton()
  }

  updateRegenerateButton() {
    if (!this.hasRegenerateButtonTarget) return

    const item = this.itemTargets[this.currentIndexValue]
    const completed = item?.dataset.sceneStatus === 'COMPLETED'
    const narration = this.hasNarrationTarget ? this.narrationTarget.value : ''
    const changed = narration !== this._originalNarration

    this.setRegenerateDisabled(!completed || !changed)
  }

  updateNavButtons() {
    const last = this.itemTargets.length - 1
    if (this.hasPrevButtonTarget) this.prevButtonTarget.disabled = this.currentIndexValue === 0
    if (this.hasNextButtonTarget) this.nextButtonTarget.disabled = this.currentIndexValue === last
  }

  setRegenerateDisabled(disabled) {
    if (!this.hasRegenerateButtonTarget) return
    this.regenerateButtonTarget.classList.toggle('opacity-50', disabled)
    this.regenerateButtonTarget.classList.toggle('pointer-events-none', disabled)
    this.regenerateButtonTarget.classList.toggle('cursor-not-allowed', disabled)
  }
}
