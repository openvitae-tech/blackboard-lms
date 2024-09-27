import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "course"
      ];
    connect(){
        console.log("hi");
        this.courseTarget.querySelector('[name="search"]').classList.remove("hidden");
        this.courseTarget.querySelector('[name="search-mobile"]').classList.remove("hidden");


    }
}