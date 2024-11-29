import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["noticeBody"];
    connect() {
        setTimeout(() => {
            this.removeNotice();
        }, 2000)
    }

    closeNotice(event) {
        event.preventDefault();
        this.removeNotice();
    }

    removeNotice() {
        this.noticeBodyTarget.classList.add("hidden");
        this.noticeBodyTarget.parentElement.removeAttribute("src");
        this.noticeBodyTarget.parentElement.removeAttribute("complete");
        this.noticeBodyTarget.parentElement.innerText = "";
    }
}
