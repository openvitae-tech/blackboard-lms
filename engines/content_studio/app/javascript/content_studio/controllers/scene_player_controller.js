import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['video', 'placeholder', 'narration', 'item']
  static values = {
    currentIndex: { type: Number, default: 0 }
  }

  connect() {
    if (this.itemTargets.length > 0) {
      this.loadScene(0)
    }
  }

  select(event) {
    const index = parseInt(event.currentTarget.dataset.sceneIndex, 10)
    this.loadScene(index)
    if (this.hasVideoTarget && this.videoTarget.src) {
      this.videoTarget.play().catch(() => {})
    }
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
      } else {
        this.videoTarget.src = ''
        this.videoTarget.classList.add('hidden')
        this.placeholderTarget.classList.remove('hidden')
      }
    }

    this.currentIndexValue = index
  }
}
