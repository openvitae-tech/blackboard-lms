import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["details"];

  connect() {
    this.openCurrentModule();
  }

  openCurrentModule() {
    const currentModule = this.detailsTargets.find((details) => {
      return details.dataset.currentModule === "true";
    });

    if (currentModule) {
      currentModule.setAttribute("open", true);
    }
  }
}
