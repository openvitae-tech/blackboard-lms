import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "allUsersSection",
    "showAllLink"
  ];
  toggleAllUsers(event) {
    event.preventDefault();
    this.showAllLinkTarget.classList.add("hidden");
    this.allUsersSectionTarget.classList.remove("hidden");

  }
}