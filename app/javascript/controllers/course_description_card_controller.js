import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    static targets = ["showMoreToggle", "courseDescription"];
    connect() {
        console.log("Course card controller active")
    }

    showMoreToggle(event) {
        console.log(this.showMoreToggleTarget);
        if (this.courseDescriptionTarget.classList.contains("show-more-desc")) {
            this.showMoreToggleTarget.firstElementChild.innerHTML = "Show more"
            this.courseDescriptionTarget.classList.remove("show-more-desc");
        } else {
            this.showMoreToggleTarget.firstElementChild.innerHTML = "Show less"
            this.courseDescriptionTarget.classList.add("show-more-desc");
        }
    }
}
