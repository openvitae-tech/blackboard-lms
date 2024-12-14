import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ['notificationList']
    path = "/notifications/count"
    headers = { 'Accept' : 'text/vnd.turbo-stream.html' }
    connect() {
        console.log("Notifications controller");
        const checkNotificationInterval = setInterval(() => {
            console.log("Fetching notification counts")
            fetch(this.path, { headers: this.headers })
                .then(response => response.text())
                .then(html => Turbo.renderStreamMessage(html))
                .catch(error => console.log(error))
        }, 50000);

        // clear the interval after 24 hours
        setTimeout(() => {
            clearInterval(checkNotificationInterval)
        }, 100000);

        window.addEventListener("click",(e) => {
            if (!this.notificationListTarget.contains(e.target)) {
                this.notificationListTarget.innerHTML = ""
            }
        })
    }
}