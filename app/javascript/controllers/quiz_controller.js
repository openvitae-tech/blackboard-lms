import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  valueChanged() {
    document.getElementById("quiz-submit-button").classList.remove("btn-disabled");
  }
}
