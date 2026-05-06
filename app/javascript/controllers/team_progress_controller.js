import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["membersView", "subTeamsView", "membersBtn", "subTeamsBtn", "membersLink", "subTeamsLink"]

  showMembers() {
    this.membersViewTarget.classList.remove("hidden")
    this.subTeamsViewTarget.classList.add("hidden")
    this.membersLinkTarget.classList.remove("hidden")
    if (this.hasSubTeamsLinkTarget) this.subTeamsLinkTarget.classList.add("hidden")
  }

  showSubTeams() {
    this.subTeamsViewTarget.classList.remove("hidden")
    this.membersViewTarget.classList.add("hidden")
    if (this.hasSubTeamsLinkTarget) this.subTeamsLinkTarget.classList.remove("hidden")
    this.membersLinkTarget.classList.add("hidden")
  }
}
