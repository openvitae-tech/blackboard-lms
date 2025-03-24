import { Controller } from "@hotwired/stimulus";
import Logger from "utils/logger";

export default class extends Controller {
  static targets = ["notificationList", "polingInterval"];
  path = "/notifications/count";
  headers = { Accept: "text/vnd.turbo-stream.html" };

  connect() {
    const interval = parseInt(this.polingIntervalTarget.dataset.interval);

    // Delay polling start by 3 minutes (180000 ms) to avoid immediate requests on page load
    setTimeout(() => this.initializeNotification(interval), 180000);

    window.addEventListener("click", (e) => {
      if (!this.notificationListTarget.contains(e.target)) {
        this.close(e);
      }
    });
  }

  initializeNotification(interval) {
    const checkNotificationInterval = setInterval(() => {
      this.fetchNotifications();
    }, interval * 1000); 

    // clear the interval after 24 hours
    setTimeout(() => clearInterval(checkNotificationInterval), 86400 * 1000);
  }

  
  fetchNotifications() {
    fetch(this.path, { headers: this.headers })
      .then((response) => response.text())
      .then((html) => Turbo.renderStreamMessage(html))
      .catch((error) => Logger.error(error));
  }

  close(event) {
    event.stopPropagation();
    this.notificationListTarget.innerHTML = "";
  }
}
