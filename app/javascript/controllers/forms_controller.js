import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["fileInput", "selectedFileName"];

    connect() {
        this.fileInputTarget.addEventListener("change", (e) => {
            const fileName = e.target.files[0]?.name || "No file chosen";
            this.selectedFileNameTarget.innerText = fileName;
        });
    }

    chooseFile(event) {
        console.log("Clicked this");
        this.fileInputTarget.click();
    }
}
