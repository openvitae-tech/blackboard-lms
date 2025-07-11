import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["dropdown"];

  updateSelect(event) {
    const selectedTeamId = event.target.value;

    if (!selectedTeamId) return;

    fetch(`/teams/${selectedTeamId}/sub_teams`)
      .then((response) => response.text())
      .then((html) => {
        this.dropdownTarget.innerHTML = html;
      });
  }
}
