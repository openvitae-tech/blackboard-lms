import {
   Controller
} from "@hotwired/stimulus";

export default class extends Controller {
   static targets = [
      "chooseFile",
      "fileInput",
      "selectedFileName",
      "preview",
      "previewContainer",
      "iconPreview",
   ];

   connect() {
      this.fileInputTarget.addEventListener("change", (e) => {
         const file = e.target.files[0];
         this.updateFileName(file);
         this.showPreview(file);
      });
   }

   updateFileName(file) {
      this.clearError();
      this.chooseFileTarget.classList.add("hidden");
      this.selectedFileNameTarget.classList.remove("hidden");

      if (file) {
         const fileName = file.name;
         const fileSize = this.formatFileSize(file.size);
         this.selectedFileNameTarget.innerHTML = `
      <span class="block">${fileName}</span>
      <span class="block">${fileSize}</span>
    `;
      } else {
         this.selectedFileNameTarget.innerText = "No file chosen";
      }
   }

   formatFileSize(bytes) {
      if (bytes < 1024) return `${bytes} B`;
      if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
      return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
   }


   showPreview(file) {
      if (!file) return;

      const fileType = file.type;
      this.previewContainerTarget.classList.remove("hidden");

      if (fileType.startsWith("image/")) {
         const reader = new FileReader();
         reader.onload = () => {
            this.previewTarget.src = reader.result;
         };
         reader.readAsDataURL(file);
      } else {
         this.previewTarget.src = "";
      }
   }

   showError(message) {
      this.resetInput();
      this.selectedFileNameTarget.innerText = message;
      this.selectedFileNameTarget.style.color = "red";
   }

   clearError() {
      this.selectedFileNameTarget.innerText = "No file chosen";
      this.selectedFileNameTarget.style.color = "";
   }

   resetInput() {
      this.fileInputTarget.value = "";
      this.selectedFileNameTarget.innerHTML = "";
      this.selectedFileNameTarget.classList.add("hidden");
      this.previewContainerTarget.classList.add("hidden");
      if (this.hasPreviewTarget && this.previewTarget.src) {
        this.previewTarget.src = "";
      } 
      this.chooseFileTarget.classList.remove("hidden");
   }

   chooseFile(event) {
    if (!this.chooseFileTarget.classList.contains("hidden")) {
      this.fileInputTarget.click();
    }
   }
}