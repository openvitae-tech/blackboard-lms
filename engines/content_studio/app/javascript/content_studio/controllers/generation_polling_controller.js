import { Controller } from "@hotwired/stimulus"
import "@lottiefiles/lottie-player"

export default class extends Controller {
  static values = {
    statusUrl: String,
    pollInterval: { type: Number, default: 3000 }
  }

  connect() {
    this.timer = setInterval(() => this.poll(), this.pollIntervalValue)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  async poll() {
    const response = await fetch(this.statusUrlValue, { headers: { Accept: 'application/json' } })
    const data = await response.json()
    if (data.status === 'complete') {
      clearInterval(this.timer)
      window.location.href = data.redirect_url
    }
  }
}
