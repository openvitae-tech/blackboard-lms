import { Controller } from "@hotwired/stimulus";
import { Turbo } from "@hotwired/turbo-rails";

export default class extends Controller {
  static targets = ["dropdown"];

  updateSelect(event) {
    const selectedRole = event.target.value;
    const userID = this.dropdownTarget.dataset.roleChangeUserId;
    if (!selectedRole || !userID) return;

    const url = `/member/${encodeURIComponent(userID)}/select_roles?selected=${encodeURIComponent(selectedRole)}`;
    fetch(url, { headers: { 
        Accept: "text/vnd.turbo-stream.html" },
        credentials: "same-origin"
      }).then((response) => {
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return response.text()
      }).then((html) => {
        Turbo.renderStreamMessage(html)
      }).catch((error) => {
        console.error("Role select refresh failed:", error);
      });
  }
}
