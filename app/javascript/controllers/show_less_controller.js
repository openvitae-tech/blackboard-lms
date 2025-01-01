import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "showMoreToggle",
    "upArrow",
    "downArrow",
    "courseDescription",
  ];
  connect() {
    this.checkTruncation();

    window.addEventListener("resize", this.checkTruncation.bind(this));
  }

  disconnect() {
    window.removeEventListener("resize", this.checkTruncation.bind(this));
  }

  checkTruncation() {
    const isExpanded = this.courseDescriptionTarget.classList.contains(
      "max-h-auto"
    );

    const isTruncated =
      this.courseDescriptionTarget.scrollHeight >
      this.courseDescriptionTarget.offsetHeight;

    if (isTruncated) {
      this.showMoreToggleTarget.classList.remove("invisible", "opacity-0");
    } else {
      this.showMoreToggleTarget.classList.add("invisible", "opacity-0");
      if (isExpanded) {
        this.showMoreToggle();
      }
    }
  }

  showMoreToggle(event) {
    if (this.courseDescriptionTarget.classList.contains("max-h-auto")) {
      // Collapse the description
      this.showMoreToggleTarget.firstElementChild.innerHTML = "Show more";
      this.upArrowTarget.classList.add("hidden");
      this.upArrowTarget.classList.remove("icon");
      this.downArrowTarget.classList.remove("hidden");
      this.downArrowTarget.classList.add("icon");
      this.courseDescriptionTarget.classList.remove("max-h-auto");
      this.courseDescriptionTarget.classList.add("max-h-10");
    } else {
      // Expand the description
      this.showMoreToggleTarget.firstElementChild.innerHTML = "Show less";
      this.upArrowTarget.classList.remove("hidden");
      this.upArrowTarget.classList.add("icon");
      this.downArrowTarget.classList.add("hidden");
      this.downArrowTarget.classList.remove("icon");
      this.courseDescriptionTarget.classList.remove("max-h-10");
      this.courseDescriptionTarget.classList.add("max-h-auto");
    }
  }
}
