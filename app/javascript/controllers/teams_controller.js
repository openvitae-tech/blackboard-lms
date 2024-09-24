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
    const buttonDataAction = event.currentTarget.dataset.actiontype;
    if (buttonDataAction === "addUser") {
      this.inviteUserPopupTarget.classList.remove("hidden");
    } else if (buttonDataAction === "addTeam") {
      this.addTeamPopupTarget.classList.remove("hidden");
    }
  }

  closePopup(event) {
    const buttonDataAction = event.currentTarget.dataset.actiontype;
    if (buttonDataAction === "addUserNo") {
      this.inviteUserPopupTarget.classList.add("hidden");
    } else if (buttonDataAction === "addTeamNo") {
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
    console.log("hi");
    const inputId = event.currentTarget.dataset.content;
    const fileName = event.target.files[0]?.name || "No file chosen";
    if (inputId === "logoFileInput") {
      this.logoFileLabelTarget.textContent = fileName; 
    } else if (inputId === "csvFileInput") {
      this.csvFileLabelTarget.textContent = fileName; 
    }
  }
}
