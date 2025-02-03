import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["notificationList", "polingInterval"];
  path = "/notifications/count";
  headers = { Accept: "text/vnd.turbo-stream.html" };
  connect() {
    const interval = parseInt(this.polingIntervalTarget.dataset.interval);
    const checkNotificationInterval = setInterval(() => {
      fetch(this.path, { headers: this.headers })
        .then((response) => response.text())
        .then((html) => Turbo.renderStreamMessage(html));
    }, interval * 1000);

    // clear the interval after 24 hours
    setTimeout(() => {
      clearInterval(checkNotificationInterval);
    }, 86400 * 1000);

    window.addEventListener("click", (e) => {
      if (!this.notificationListTarget.contains(e.target)) {
        this.close(e);
      }
    });
  }

  close(event) {
    event.stopPropagation();
    this.notificationListTarget.innerHTML = "";
  }
}
