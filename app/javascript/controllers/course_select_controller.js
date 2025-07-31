import { Controller } from "@hotwired/stimulus";

export default class extends Controller {

    connect() {
        this.showDuration = this.element.dataset.showDuration === "true";
    }
}
