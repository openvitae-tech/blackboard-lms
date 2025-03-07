import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["videoPlayer", "completeButton"];

  connect() {
    this.player = new Vimeo.Player(this.videoPlayerTarget);

    this.player.getDuration().then((duration) => {
      this.completionThreshold = duration * (0.90 + Math.random() * 0.05);
    });

    ["play", "pause", "ended"].forEach(event => {
      this.player.on(event, () => this.handleEvent(event));
    });

    this.player.on("timeupdate", (data) => this.checkCompletion(data.seconds));
  }

  async handleEvent(eventType) {
    let duration = await this.player.getDuration();
    let currentTime = eventType === "ended" ? duration : await this.player.getCurrentTime();
    let remainingTime = duration - currentTime;

    let formattedCurrentTime = this.formatTime(currentTime);
    let formattedRemainingTime = this.formatTime(remainingTime);

    alert(`Video ${eventType} at ${formattedCurrentTime}\nRemaining: ${formattedRemainingTime}`);

    if (eventType === "ended") {
      await this.handleVideoEnd();
    }
  }

  checkCompletion(currentTime) {
    if (currentTime >= this.completionThreshold) {
      this.enableCompleteButton();
    }
  }

  handleVideoEnd() {
    this.player.pause();

    if (this.hasCompleteButtonTarget) {
      this.enableCompleteButton();
    }
  }

  enableCompleteButton() {
    if (this.hasCompleteButtonTarget) {
      this.completeButtonTarget.classList.remove("disabled");
      this.completeButtonTarget.removeAttribute("disabled");
    }
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
