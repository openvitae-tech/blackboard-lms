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
      "max-h-[max-content]"
    );
    const isTruncated =
      this.courseDescriptionTarget.scrollHeight >
      this.courseDescriptionTarget.offsetHeight;

    if (isTruncated) {
      this.showMoreToggleTarget.classList.remove("hidden");
    } else {
      if (isExpanded) {
        this.showMoreToggle();
      }
      this.showMoreToggleTarget.classList.add("hidden");
    }
  }

  showMoreToggle(event) {
    if (
      this.courseDescriptionTarget.classList.contains("max-h-[max-content]")
    ) {
      this.showMoreToggleTarget.firstElementChild.innerHTML = "Show more";
      this.upArrowTarget.classList.add("hidden");
      this.upArrowTarget.classList.remove("icon");
      this.downArrowTarget.classList.remove("hidden");
      this.downArrowTarget.classList.add("icon");
      this.courseDescriptionTarget.classList.remove("max-h-[max-content]");
      this.courseDescriptionTarget.classList.add("max-h-10");
    } else {
      this.showMoreToggleTarget.firstElementChild.innerHTML = "Show less";
      this.upArrowTarget.classList.remove("hidden");
      this.upArrowTarget.classList.add("icon");
      this.downArrowTarget.classList.add("hidden");
      this.downArrowTarget.classList.remove("icon");
      this.courseDescriptionTarget.classList.remove("max-h-10");
      this.courseDescriptionTarget.classList.add("max-h-[max-content]");
    }
  }
}
