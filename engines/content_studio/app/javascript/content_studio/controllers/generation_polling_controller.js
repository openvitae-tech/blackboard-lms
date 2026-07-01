import { Controller } from "@hotwired/stimulus"
import "@lottiefiles/lottie-player"

export default class extends Controller {
  static values = {
    statusUrl: String,
    startUrl: String,
    pollInterval: { type: Number, default: 3000 }
  }

  static targets = ['stage', 'uploadPhase', 'craftingPhase', 'errorPhase']

  async connect() {
    if (this.startUrlValue) {
      const storageKey = `generation_started_${this.startUrlValue}`
      const existing = sessionStorage.getItem(storageKey)
      if (existing && (Date.now() - parseInt(existing)) < 60000) return
      sessionStorage.setItem(storageKey, Date.now().toString())
      // Run API call and phase transitions in parallel
      // Minimum display: 4s uploading + 4s crafting before redirect
      try {
        const [result] = await Promise.all([
          this.startGeneration(),
          this.runPhaseTransitions()
        ])
        if (result?.redirect_url) { window.location.href = result.redirect_url; return }
      } catch {
        // silent — error page only shown when server returns state=error
      } finally {
        sessionStorage.removeItem(storageKey)
      }
      // status_url was set by startGeneration — begin polling
      if (this.statusUrlValue) {
        this.timer = setInterval(() => this.poll(), this.pollIntervalValue)
      }
      return
    }
    this.timer = setInterval(() => this.poll(), this.pollIntervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  switchToCraftingPhase() {
    if (this.hasUploadPhaseTarget)   this.uploadPhaseTarget.classList.add('hidden')
    if (this.hasCraftingPhaseTarget) this.craftingPhaseTarget.classList.remove('hidden')
  }

  async startGeneration() {
    const csrfToken = document.querySelector('meta[name="csrf-token"]')?.content ?? ''
    const response = await fetch(this.startUrlValue, {
      method: 'POST',
      headers: { 'X-CSRF-Token': csrfToken, Accept: 'application/json' }
    })
    const data = await response.json()
    if (data.redirect_url) return data
    this.statusUrlValue = data.status_url
    return null
  }

  async runPhaseTransitions() {
    // Show uploading for 4s, then crafting for 4s
    await this.delay(4000)
    this.switchToCraftingPhase()
    await this.delay(4000)
  }

  delay(ms) {
    return new Promise(resolve => setTimeout(resolve, ms))
  }

  showErrorPhase() {
    if (this.hasUploadPhaseTarget)   this.uploadPhaseTarget.classList.add('hidden')
    if (this.hasCraftingPhaseTarget) this.craftingPhaseTarget.classList.add('hidden')
    if (this.hasErrorPhaseTarget)    this.errorPhaseTarget.classList.remove('hidden')
    clearInterval(this.timer)
  }

  async poll() {
    if (!this.statusUrlValue) return
    const response = await fetch(this.statusUrlValue, { headers: { Accept: 'application/json' } })
    if (!response.ok) { this.showErrorPhase(); return }
    const data = await response.json()

    if (data.stage && this.hasStageTarget) {
      this.stageTarget.textContent = data.stage
    }

    if (data.stage && this.hasUploadPhaseTarget && this.hasCraftingPhaseTarget) {
      const crafting = data.stage.toLowerCase().includes('craft') ||
                       data.stage.toLowerCase().includes('generat') ||
                       data.stage.toLowerCase().includes('structur')
      this.uploadPhaseTarget.classList.toggle('hidden', crafting)
      this.craftingPhaseTarget.classList.toggle('hidden', !crafting)
    }

    if (data.status === 'complete' || data.status === 'error') {
      clearInterval(this.timer)
      window.location.href = data.redirect_url
    }
  }
}
