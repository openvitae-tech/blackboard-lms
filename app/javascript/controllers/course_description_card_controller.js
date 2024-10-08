import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

    static targets = ["showMoreToggle","upArrow","downArrow", "courseDescription"];
    connect() {
        console.log("Course card controller active")
    }

    showMoreToggle(event) {
        console.log(this.showMoreToggleTarget);
        if (this.courseDescriptionTarget.classList.contains("show-more-desc")) {
            this.showMoreToggleTarget.firstElementChild.innerHTML = "Show more"

            this.upArrowTarget.classList.add("hidden")
            this.upArrowTarget.classList.remove("icon")
            this.downArrowTarget.classList.remove("hidden")
            this.downArrowTarget.classList.add("icon")

            this.courseDescriptionTarget.classList.remove("show-more-desc");
        } else {
            this.showMoreToggleTarget.firstElementChild.innerHTML = "Show less"
            
            this.upArrowTarget.classList.remove("hidden")
            this.upArrowTarget.classList.add("icon")
            this.downArrowTarget.classList.add("hidden")
            this.downArrowTarget.classList.remove("icon")

            this.courseDescriptionTarget.classList.add("show-more-desc");
        }
    }
}
