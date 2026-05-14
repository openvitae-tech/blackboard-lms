import { Controller } from "@hotwired/stimulus"
import "@lottiefiles/lottie-player"

export default class extends Controller {
  static values = {
    statusUrl: String,
    startUrl: String,
    pollInterval: { type: Number, default: 3000 }
  }

  static targets = ['stage']

  async connect() {
    if (this.startUrlValue) {
      const ok = await this.startGeneration()
      if (!ok) return
    }
    this.timer = setInterval(() => this.poll(), this.pollIntervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  async startGeneration() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content ?? ''
    const response = await fetch(this.startUrlValue, {
      method: 'POST',
      headers: { 'X-CSRF-Token': csrfToken, Accept: 'application/json' }
    })
    const data = await response.json()
    if (!response.ok || data.error) {
      if (this.hasStageTarget) this.stageTarget.textContent = data.error || 'Failed to start generation'
      return false
    }
    this.statusUrlValue = data.status_url
    return true
  }

  async poll() {
    if (!this.statusUrlValue) return
    const response = await fetch(this.statusUrlValue, { headers: { Accept: 'application/json' } })
    const data = await response.json()

    if (data.stage && this.hasStageTarget) {
      this.stageTarget.textContent = data.stage
    }

    if (data.status === 'complete') {
      clearInterval(this.timer)
      window.location.href = data.redirect_url
    }
  }
}
