import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dropdown"];

  updateSelect(event) {
    const selectedRole = event.target.value;
    const userID = this.dropdownTarget.dataset.roleChangeUserId;
    if (!selectedRole || !userID) return;

    fetch(`/member/${userID}/select_roles?selected=${selectedRole}`)
      .then((response) => response.text())
      .then((html) => {
        this.dropdownTarget.innerHTML = html;
      });
  }
}
