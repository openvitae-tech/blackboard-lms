import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    connect() {
        self.startTime = new Date();
    }

    completeLesson(event) {
        let duration = new Date() - self.startTime;
        duration = Math.round(duration/1000);
        const time_spent = document.getElementsByName("time_spent")[0];
        time_spent.value = duration;
    }
}
