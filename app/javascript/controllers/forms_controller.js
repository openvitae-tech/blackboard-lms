import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "fileInput",
    "selectedFileName",
    "logoPreview",
    "logoPreviewContainer",
    "bannerPreview",
    "bannerPreviewContainer"
  ];

  connect() {
    this.fileInputTarget.addEventListener("change", (e) => {
      const fileName = e.target.files[0];
      this.updateFileName(fileName);
      this.showPreview(fileName);
    });
  }

  updateFileName(file) {
    const fileName = file ? file.name : "No file chosen";
    this.selectedFileNameTarget.innerText = fileName;
  }

  showPreview(file) {
    const fileType = this.fileInputTarget.dataset.fileType;

    if (file && file.type.startsWith("image/")) {
      const reader = new FileReader();
      reader.onload = () => {
        if (fileType === "logo") {
          this.logoPreviewTarget.src = reader.result;
          this.logoPreviewContainerTarget.classList.remove("hidden");
        } else if (fileType === "banner") {
          this.bannerPreviewTarget.src = reader.result;
          this.bannerPreviewContainerTarget.classList.remove("hidden");
        }
      };
      reader.readAsDataURL(file);
    }
  }

  resetInput(event) {
    const fileType = event.currentTarget.dataset.fileType;

    if (fileType === "logo") {
      this.logoPreviewContainerTarget.classList.add("hidden");
      this.logoPreviewTarget.src = "";
    } else if (fileType === "banner") {
      this.bannerPreviewContainerTarget.classList.add("hidden");
      this.bannerPreviewTarget.src = "";
    }

    this.fileInputTarget.value = "";
    this.selectedFileNameTarget.innerText = "No file chosen";
  }

  chooseFile(event) {
    this.fileInputTarget.click();
  }
}
