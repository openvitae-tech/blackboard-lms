import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    const modalEl = document.getElementById("app-modal");
    this.modal = new Modal(modalEl);
  }

  open() {
    if (this.modal.isHidden()) {
      this.modal.show();
    }
  }

  close(event) {
    event.preventDefault();
    if (this.modal.isVisible()) {
      this.modal.hide();
      const modalContent = document.getElementById("modal");
      modalContent.innerHTML = "";
      modalContent.removeAttribute("src");
      modalContent.removeAttribute("complete");
    }
  }

  afterSubmit(event) {
    if (event.detail.success) {
      const fetchResponse = event.detail.fetchResponse
      history.pushState(
          { turbo_frame_history: true },
          "",
          fetchResponse.response.url
      )

      Turbo.visit(fetchResponse.response.url)
    }
  }
}
