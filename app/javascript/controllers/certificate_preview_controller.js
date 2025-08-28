import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["htmlInput", "previewArea"];

  connect() {
    if (this.hasHtmlInputTarget) {
      this.render();
    }
  }

  render() {
    this.previewAreaTarget.innerHTML = this.htmlInputTarget.value;
  }
}
