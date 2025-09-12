import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "vimeoLoader",
    "vimeoPlayer",
    "completeButtonForm",
    "completeButton",
    "completionOverlay"
  ];

  connect() {
    // return if the vimeo player is not present, for example in local
    if (!this.hasVimeoPlayerTarget) return;

    this.disableCompleteButton();

    if (this.hasVimeoLoaderTarget) {
      // show loader
      this.showLoader();
      // hide the loader once the video is loaded
      this.vimeoPlayerTarget.addEventListener("load", () => this.hideLoader());
    }

    this.player = new Vimeo.Player(this.vimeoPlayerTarget);

    this.player.getDuration().then((duration) => {
      // generate a random duration between 87% to 97% as completion threshold
      this.completionThreshold = Math.floor(Math.random() * 11 + 87);
    });

    this.player.on("loaded", (event) => this.handleLoadVideo(event));
    this.player.on("play", (event) => this.handlePlayVideo(event));
    this.player.on("pause", (event) => this.handlePauseVideo(event));
    this.player.on("ended", (event) => this.handleEndVideo(event));
    this.player.on("timeupdate", (event) => this.checkCompletion(event));
  }

  async handleLoadVideo(event) {
    self.timeSpent = 0;
    self.startTime = null;
    this.updateTimeSpent();
  }

  async handlePlayVideo(event) {
    self.startTime = new Date();
  
    const iframe = this.vimeoPlayerTarget;
    const shouldFullscreen = iframe.dataset.fullscreenOnce === "true";
  
    if (!document.fullscreenElement && shouldFullscreen) {
      this.requestFullscreen(iframe);
      iframe.dataset.fullscreenOnce = "false";
    }
  }
  
  async handlePauseVideo(event) {
    this.updateTimeSpent();
  }

  async handleEndVideo(event) {
    this.updateTimeSpent();
    this.enableCompleteButton();
    if (document.fullscreenElement === this.vimeoPlayerTarget) {
      await document.exitFullscreen();
    }
  
    if (this.hasCompletionOverlayTarget) {
        this.completionOverlayTarget.classList.remove("hidden");
    }
  }

  requestFullscreen(element) {
    if (element.requestFullscreen) {
      element.requestFullscreen();
    } else if (element.webkitRequestFullscreen) {
      element.webkitRequestFullscreen();
    } else if (element.msRequestFullscreen) {
      element.msRequestFullscreen();
    }
  }
  
  updateTimeSpent() {
    const duration = self.startTime ? new Date() - self.startTime : 0;
    self.timeSpent = self.timeSpent + duration;
    // set the time spent in the hidden form field of complete button
    if (this.hasCompleteButtonTarget) {
      const form = this.completeButtonTarget.closest("form");
      const time_spent = form.querySelector('input[name="time_spent"]');
      time_spent.value = self.timeSpent / 1000;
    }
  }

  checkCompletion(event) {
    const completionPercentage = event.percent * 100;
    if (completionPercentage >= this.completionThreshold) {
      this.enableCompleteButton();
    }
  }
  enableCompleteButton() {
    if (this.hasCompleteButtonTarget) {
      this.completeButtonFormTarget.classList.remove("disabled");
      this.completeButtonTarget.classList.remove("bg-slate-grey-text", "hover:bg-slate-grey-light");
      this.completeButtonTarget.classList.add("bg-primary", "hover:bg-primary-light");
  
      const tooltip = this.completeButtonTarget.querySelector(".tooltip");
      if (tooltip) tooltip.classList.add("hidden");
    }
  }

  disableCompleteButton() {
    if (this.hasCompleteButtonTarget) {
      this.completeButtonFormTarget.classList.add("disabled");
      this.completeButtonTarget.classList.remove("bg-primary", "hover:bg-primary-light");
      this.completeButtonTarget.classList.add("bg-slate-grey-text", "hover:bg-slate-grey-light");
 
      const tooltip = this.completeButtonTarget.querySelector(".tooltip");
      if (tooltip) tooltip.classList.remove("hidden");
    }
  }

  showLoader() {
    this.vimeoLoaderTarget.classList.remove("hidden");
  }
  hideLoader() {
    this.vimeoLoaderTarget.classList.add("hidden");
  }
  rewatch(event) {
    event.preventDefault();
    const iframe = this.vimeoPlayerTarget;
  
    if (this.hasCompletionOverlayTarget) {
      this.completionOverlayTarget.classList.add("hidden");
    }
    
    iframe.dataset.fullscreenOnce = "false";
  
    const resetAndPlay = async () => {
      try {
        await this.player.setCurrentTime(0);
        await this.player.play();
      } catch (_) {
      }
    };
  
    resetAndPlay();
  }
  
  
}
