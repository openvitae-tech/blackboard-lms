import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["loader"]

  connect() {
    this.element.addEventListener("submit", this.showLoader.bind(this))
  }

  showLoader(event) {
    this.loaderTarget.classList.remove("hidden")
  }
}
