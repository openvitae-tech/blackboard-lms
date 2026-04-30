import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["membersView", "subTeamsView", "membersBtn", "subTeamsBtn"]

  showMembers() {
    this.membersViewTarget.classList.remove("hidden")
    this.subTeamsViewTarget.classList.add("hidden")
  }

  showSubTeams() {
    this.subTeamsViewTarget.classList.remove("hidden")
    this.membersViewTarget.classList.add("hidden")
  }
}
