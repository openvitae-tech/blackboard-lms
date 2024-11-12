import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["modalBox","submitButton"];
  connect() {
    console.log("Modal connected");
  }

  closeModal(event) {
    event.preventDefault();
    this.modalBoxTarget.classList.add("hidden");
    this.modalBoxTarget.parentElement.removeAttribute("src");
    this.modalBoxTarget.parentElement.removeAttribute("complete");
    this.modalBoxTarget.parentElement.innerText = "";
  }
  submitModal(){
    this.submitButtonTarget.classList.remove("bg-primary");
    this.submitButtonTarget.classList.add("btn-default");
    this.submitButtonTarget.innerHTML = "Submitting...";
 
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
    this.submitButtonTarget.classList.add("btn-default");

    this.submitButtonTarget.setAttribute("disabled");
  }
}
