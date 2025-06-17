import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  validateInput(event) {
    event.target.value = event.target.value.slice(0, 10);
  }
}