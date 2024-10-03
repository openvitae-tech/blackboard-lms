import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "allUsersSection",
    "showAllUsers"
  ];
  toggleAllUsers(event) {
    event.preventDefault();
    this.showAllUsersTarget.classList.add("hidden");
    this.allUsersSectionTarget.classList.remove("hidden");
  }
}