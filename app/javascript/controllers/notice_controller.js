import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["noticeBody"];
    connect() {
    }

    closeNotice(event) {
        event.preventDefault();
        this.noticeBodyTarget.classList.add("hidden");
        this.noticeBodyTarget.parentElement.removeAttribute("src");
        this.noticeBodyTarget.parentElement.removeAttribute("complete");
        this.noticeBodyTarget.parentElement.innerText = "";
    }
}
