import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "textarea",
    "approveAction",
    "editActions",
    "thumbnail",
    "previewModal",
    "previewVideo",
  ];

  static values = {
    approveUrl: String,
    regenerateUrl: String,
    disabled: Boolean,
  };

  connect() {
    this.originalScript = this.hasTextareaTarget ? this.textareaTarget.value : "";
    this._handleEditEntered = this.handleEditEntered.bind(this);
    this._handleEditExited = this.handleEditExited.bind(this);

    document.addEventListener("scene:edit-entered", this._handleEditEntered);
    document.addEventListener("scene:edit-exited", this._handleEditExited);
  }

  disconnect() {
    document.removeEventListener("scene:edit-entered", this._handleEditEntered);
    document.removeEventListener("scene:edit-exited", this._handleEditExited);
  }

  handleEditEntered(event) {
    if (event.detail.source === this.element) return;

    this.setDisabled(true);
  }

  handleEditExited() {
    this.setDisabled(false);
  }

  setDisabled(disabled) {
    this.disabledValue = disabled;
    this.element.classList.toggle("opacity-40", disabled);
    this.element.classList.toggle("pointer-events-none", disabled);
  }

  enterEdit() {
    if (this.disabledValue || !this.hasTextareaTarget) return;

    this.originalScript = this.textareaTarget.value;
    this.textareaTarget.readOnly = false;
    this.textareaTarget.classList.remove("border-slate-grey-50");
    this.textareaTarget.classList.add("border-2", "border-primary");
    this.textareaTarget.focus();

    if (this.hasApproveActionTarget) this.approveActionTarget.classList.add("hidden");
    if (this.hasEditActionsTarget) this.editActionsTarget.classList.remove("hidden");

    document.dispatchEvent(new CustomEvent("scene:edit-entered", { detail: { source: this.element } }));
  }

  cancel() {
    if (this.hasTextareaTarget) this.textareaTarget.value = this.originalScript;

    this.exitEdit();
  }

  exitEdit() {
    if (this.hasTextareaTarget) {
      this.textareaTarget.readOnly = true;
      this.textareaTarget.classList.remove("border-2", "border-primary");
      this.textareaTarget.classList.add("border-slate-grey-50");
    }

    if (this.hasEditActionsTarget) this.editActionsTarget.classList.add("hidden");
    if (this.hasApproveActionTarget) this.approveActionTarget.classList.remove("hidden");

    document.dispatchEvent(new CustomEvent("scene:edit-exited", { detail: { source: this.element } }));
  }

  approve() {
    this.post(this.approveUrlValue, { script: this.hasTextareaTarget ? this.textareaTarget.value : undefined });
    this.showProcessing();
  }

  regenerate() {
    this.post(this.regenerateUrlValue, { script: this.hasTextareaTarget ? this.textareaTarget.value : undefined });
    this.exitEdit();
    this.showProcessing();
  }

  showProcessing() {
    if (this.hasTextareaTarget) {
      this.textareaTarget.readOnly = true;
      this.textareaTarget.disabled = true;
    }

    if (this.hasApproveActionTarget) this.approveActionTarget.classList.add("hidden");

    if (this.hasThumbnailTarget) {
      this.thumbnailTarget.innerHTML =
        '<div class="flex items-center justify-center w-full h-full"><div class="h-8 w-8 animate-spin rounded-full border-4 border-primary-light-100 border-t-primary"></div></div>';
    }
  }

  post(url, body = {}) {
    if (!url) return;

    const token = document.querySelector('meta[name="csrf-token"]')?.content;

    fetch(url, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token,
        Accept: "application/json",
      },
      body: JSON.stringify(body),
    }).catch(() => {});
  }

  openPreview() {
    if (!this.hasPreviewModalTarget) return;

    this.previewModalTarget.classList.remove("hidden");
  }

  closePreview() {
    if (!this.hasPreviewModalTarget) return;

    this.previewModalTarget.classList.add("hidden");

    if (this.hasPreviewVideoTarget) {
      this.previewVideoTarget.pause();
      this.previewVideoTarget.currentTime = 0;
    }
  }
}
