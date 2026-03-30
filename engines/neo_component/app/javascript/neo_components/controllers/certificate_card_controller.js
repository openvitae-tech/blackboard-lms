import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["overlay"];

  connect() {
    this.element.addEventListener("mouseenter", () => this.show());
    this.element.addEventListener("mouseleave", () => this.hide());
    this.element.addEventListener("focusout", (e) => this.handleFocusOut(e));
    this._handleOutsideClick = this.handleOutsideClick.bind(this);
    this._handleCloseOthers = this.handleCloseOthers.bind(this);
    this._handleScroll = () => this.hide();

    document.addEventListener("click", this._handleOutsideClick);
    document.addEventListener("certificate-card:close-others", this._handleCloseOthers);

    
    this.scrollParent.addEventListener("scroll", this._handleScroll);
  }

  disconnect() {
    document.removeEventListener("click", this._handleOutsideClick);
    document.removeEventListener("certificate-card:close-others", this._handleCloseOthers);
    this.scrollParent.removeEventListener("scroll", this._handleScroll);
  }

  toggle(event) {
    if (this.overlayTarget.contains(event.target)) return;
    event.stopPropagation();

    if (this.overlayTarget.classList.contains("opacity-0")) {
      document.dispatchEvent(new CustomEvent("certificate-card:close-others", {
        detail: { except: this.element }
      }));
      this.show();
    } else {
      this.hide();
    }
  }

  show() {
    this.overlayTarget.classList.remove("opacity-0", "pointer-events-none");
    this.overlayTarget.classList.add("opacity-100", "pointer-events-auto");
  }

  hide() {
    this.overlayTarget.classList.remove("opacity-100", "pointer-events-auto");
    this.overlayTarget.classList.add("opacity-0", "pointer-events-none");
  }

  handleFocusOut(event) {
    setTimeout(() => {
      if (!this.element.contains(document.activeElement)) {
        this.hide();
      }
    }, 100);
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.hide();
    }
  }

  handleCloseOthers(event) {
    if (event.detail.except !== this.element) {
      this.hide();
    }
  }

}