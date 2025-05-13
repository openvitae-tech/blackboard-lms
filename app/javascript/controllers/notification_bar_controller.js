import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["banner"]

  close() {
    this.bannerTarget.classList.add("hidden")
  }
}
