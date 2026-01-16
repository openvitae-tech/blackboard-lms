import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["minute1", "minute2", "second1", "second2"]
  static values = { minutes: Number }

  connect() {
    this.totalSeconds = this.minutesValue * 60
    this.updateDisplay()
    this.startTimer()
  }

  disconnect() {
    clearInterval(this.interval)
  }

  startTimer() {
    this.interval = setInterval(() => {
      if (this.totalSeconds > 0) {
        this.totalSeconds--
        this.updateDisplay()
      } else {
        clearInterval(this.interval)
        window.location.reload()
      }
    }, 1000)
  }

  updateDisplay() {
    const mins = Math.floor(this.totalSeconds / 60)
    const secs = this.totalSeconds % 60
    
    this.minute1Target.textContent = mins.toString().padStart(2, "0")[0]
    this.minute2Target.textContent = mins.toString().padStart(2, "0")[1]
    this.second1Target.textContent = secs.toString().padStart(2, "0")[0]
    this.second2Target.textContent = secs.toString().padStart(2, "0")[1]    
  }
}