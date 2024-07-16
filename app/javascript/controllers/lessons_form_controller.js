import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["nestedRecordContainer", "nestedRecordTemplate"];

    connect() {
        this.nestedRecordTemplate = this.nestedRecordTemplateTarget;
        this.nestedRecordContainer = this.nestedRecordContainerTarget;
    }

    addRecord(event) {
        const newNode = this.nestedRecordTemplate.content.cloneNode(true)
        this.replaceNewIndex(newNode);
        this.nestedRecordContainer.appendChild(newNode);
    }

    removeRecord(event) {
        const parent = event.target.parentElement.parentElement;
        parent.querySelector("input[type='hidden']").value=true;
        parent.classList.add("hidden");
    }

    replaceNewIndex(obj) {
        const timestamp = new Date().getTime();

        obj.querySelectorAll("input, select, textarea").forEach((field) => {
            field.id = new Date().getTime();
            field.name = field.name.replace("new-index", timestamp)
        })
    }
}
