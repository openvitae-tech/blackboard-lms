import { Controller } from "@hotwired/stimulus";
import consumer from "channels/consumer";

export default class extends Controller {
  static targets = ["notificationList", "notificationCount"];

  connect() {
    this.subscription();
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

  subscription() {
    consumer.subscriptions.create("NotificationsChannel", {
      received: (data) => {
        this.notificationCountTarget.innerText = data.count;
      },
    });
  }
}
