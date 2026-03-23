import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["overlay"];

  connect() {
    this.element.addEventListener("mouseenter", () => this.show());
    this.element.addEventListener("mouseleave", () => this.hide());
    this._handleOutsideClick = this.handleOutsideClick.bind(this);
    document.addEventListener("click", this._handleOutsideClick);
  }

  disconnect() {
    document.removeEventListener("click", this._handleOutsideClick);
  }

  toggle(event) {
    if (this.overlayTarget.contains(event.target)) return;
    event.stopPropagation();
    this.overlayTarget.classList.contains("opacity-0") ? this.show() : this.hide();
  }

  show() {
    this.overlayTarget.classList.remove("opacity-0", "pointer-events-none");
    this.overlayTarget.classList.add("opacity-100", "pointer-events-auto");
  }

  hide() {
    this.overlayTarget.classList.remove("opacity-100", "pointer-events-auto");
    this.overlayTarget.classList.add("opacity-0", "pointer-events-none");
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.hide();
    }
  }
}
