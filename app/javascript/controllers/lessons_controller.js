import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["timeSpent"]
    connect() {
        self.startTime = new Date();
    }

    completeLesson(event) {
        let duration = new Date() - self.startTime;
        duration = Math.round(duration/1000);
        // Doing this because there is no direct way to give an id
        // or target attribute to the time_spent hidden field
        const form = this.timeSpentTarget.closest('form');
        const time_spent = form.querySelector('input[name="time_spent"]')
        time_spent.value = duration;
        console.log("Time spent = ", time_spent.value)
    }
}
