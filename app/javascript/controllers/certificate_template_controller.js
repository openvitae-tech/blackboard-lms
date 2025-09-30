import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["fileLabel"];

  changeFileLabel(event) {
    const file = event.target.files[0];
    if (!file) return;

    this.fileLabelTarget.textContent = file.name;
  }
}
