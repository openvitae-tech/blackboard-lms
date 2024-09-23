import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "inviteUserPopup",
    "addTeamPopup",
    "logoFileInput",
    "logoFileLabel",
    "csvFileInput",
    "csvFileLabel",
  ];

  addUser(event) {
    const buttonId = event.currentTarget.id;
    console.log("hi");

    if (buttonId === "add-user-btn") {
      this.inviteUserPopupTarget.classList.remove("hidden");
    } else if (buttonId === "add-team-btn") {
      this.addTeamPopupTarget.classList.remove("hidden");
    }
  }

  closePopup(event) {
    const buttonId = event.currentTarget.id;
    if (buttonId === "user-cancel-btn" || buttonId === "cancel-btn-user") {
      this.inviteUserPopupTarget.classList.add("hidden");
    } else if (
      buttonId === "team-cancel-btn" ||
      buttonId === "cancel-btn-team"
    ) {
      this.addTeamPopupTarget.classList.add("hidden");
    }
  }
  chooseFile(event) {
    const containerId = event.currentTarget.getAttribute("data-upload-id");

    if (containerId === "upload-logo") {
      this.logoFileInputTarget.click();
    } else if (containerId === "upload-csv") {
      this.csvFileInputTarget.click();
    }
  }
  handleFileChange(event) {
    const inputId = event.currentTarget.id;
    const fileName = event.target.files[0]?.name || "No file chosen";

    if (inputId === "logo-file-input") {
      this.logoFileLabelTarget.textContent = fileName; 
    } else if (inputId === "csv-file-input") {
      this.csvFileLabelTarget.textContent = fileName; 
    }
  }
}
