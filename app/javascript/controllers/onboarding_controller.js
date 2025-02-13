import {Controller} from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "progressBar",
        "welcomeScreen",
        "step1Screen",
        "step2Screen",
        "step3Screen",
        "step4Screen",
    ];

    nextScreen(event) {
        event.preventDefault();

        let currentScreen = event.currentTarget.dataset.current;
        let nextScreen = event.currentTarget.dataset.next;

        this[currentScreen + "Target"].classList.add("hidden");
        this[nextScreen + "Target"].classList.remove("hidden");
        this.updateProgress(20);
    }

    previousScreen(event) {
        event.preventDefault();

        let currentScreen = event.currentTarget.dataset.current;
        let previousScreen = event.currentTarget.dataset.previous;

        this[currentScreen + "Target"].classList.add("hidden");
        this[previousScreen + "Target"].classList.remove("hidden");
        this.updateProgress(-20);
    }

    updateProgress(change) {
        let progress = parseInt(this.progressBarTarget.style.width);
        progress = progress + change;
        this.progressBarTarget.style.width = `${progress}%`;
    }
}