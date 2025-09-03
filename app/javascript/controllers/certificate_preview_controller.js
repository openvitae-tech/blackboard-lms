import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["htmlInput", "previewArea"];

  connect() {
    if (this.hasHtmlInputTarget) {
      this.render();
    }
  }

  render() {
    const html = this.htmlInputTarget.value;
    this.previewAreaTarget.innerHTML = "";

    const iframe = document.createElement("iframe");
    iframe.className = "w-full h-64 rounded";
    iframe.setAttribute("sandbox", "");
    iframe.srcdoc = html;

    this.previewAreaTarget.appendChild(iframe);
  }
}
