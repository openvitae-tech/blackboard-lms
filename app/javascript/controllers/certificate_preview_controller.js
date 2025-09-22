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
    iframe.className = "w-[200%] h-[200%] scale-[0.5] origin-top-left";
    iframe.setAttribute("sandbox", "");
    iframe.srcdoc = html;

    this.previewAreaTarget.appendChild(iframe);
  }
}
