import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["videoPlayer"];

  connect() {
    this.player = new Vimeo.Player(this.videoPlayerTarget);

    ["play", "pause", "ended"].forEach(event => {
      this.player.on(event, () => this.handleEvent(event));
    });
  }

  async handleEvent(eventType) {
    let duration = await this.player.getDuration();
    let currentTime = eventType === "ended" ? duration : await this.player.getCurrentTime();
    let remainingTime = duration - currentTime;

    let formattedCurrentTime = this.formatTime(currentTime);
    let formattedRemainingTime = this.formatTime(remainingTime);

    alert(`Video ${eventType} at ${formattedCurrentTime}\nRemaining: ${formattedRemainingTime}`);
  }

  formatTime(seconds) {
    let hrs = Math.floor(seconds / 3600);
    let mins = Math.floor((seconds % 3600) / 60);
    let secs = Math.floor(seconds % 60);
    return [
      hrs.toString().padStart(2, "0"),
      mins.toString().padStart(2, "0"),
      secs.toString().padStart(2, "0")
    ].join(":");
  }
}
