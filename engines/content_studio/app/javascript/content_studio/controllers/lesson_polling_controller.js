import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    pending: Boolean,
    sceneStatusUrl: String
  }

  connect() {
    if (this.pendingValue) {
      this.timer = setInterval(() => this.poll(), 5000)
    }
  }

  disconnect() {
    clearInterval(this.timer)
  }

  async poll() {
    if (!this.sceneStatusUrlValue) return
    const response = await fetch(this.sceneStatusUrlValue, { headers: { Accept: 'application/json' } })
    if (!response.ok) return
    const { scenes, pending } = await response.json()

    this.updateScenes(scenes)
    if (!pending) clearInterval(this.timer)
  }

  updateScenes(scenes) {
    const items = this.element.querySelectorAll('[data-scene-player-target="item"]')

    scenes.forEach((scene, index) => {
      const item = items[index]
      if (!item) return

      const hadVideo = !!item.dataset.videoUrl
      item.dataset.videoUrl = scene.video_url || ''
      item.dataset.sceneStatus = scene.status

      if (scene.video_url && !hadVideo) {
        this.updateThumbnail(item, scene)
        item.dispatchEvent(new CustomEvent('scene-video-ready', { bubbles: true }))
      }
    })

    this.updateProgress(scenes)
  }

  updateThumbnail(item, scene) {
    const thumbnailArea = item.querySelector('.h-\\[47px\\]')
    if (!thumbnailArea) return

    thumbnailArea.innerHTML = scene.thumbnail_url
      ? `<img src="${scene.thumbnail_url}" class="w-full h-full object-cover" alt="Scene thumbnail">`
      : `<div class="w-full h-full bg-white flex items-center justify-center">
           <svg class="w-6 h-6 text-letter-color" fill="none" viewBox="0 0 24 24" stroke="currentColor">
             <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"/>
             <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/>
           </svg>
         </div>`
  }

  updateProgress(scenes) {
    const done = scenes.filter(s => s.video_url).length
    const total = scenes.length
    const progressText = this.element.querySelector('[data-progress-text]')
    if (progressText) progressText.textContent = `${done}/${total} Scenes`

    const fill = this.element.querySelector('[data-progress-fill]')
    if (fill) fill.style.width = `${total > 0 ? (done / total) * 100 : 0}%`
  }
}
