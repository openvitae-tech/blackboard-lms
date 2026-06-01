import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["assignButton", "assignButtonInner", "modal"];

    connect() {
        this.showDuration = this.element.dataset.showDuration === "true";
    }

    toggleAssignButton() {
        const anyChecked = this.element.querySelectorAll('input[name="course_ids[]"]:checked').length > 0;

        if (anyChecked) {
            this.assignButtonTarget.removeAttribute("disabled");
            this.assignButtonInnerTarget.classList.remove("btn-disabled", "btn-solid-primary-disabled");
            this.assignButtonInnerTarget.classList.add("btn-solid-primary");
        } else {
            this.assignButtonTarget.setAttribute("disabled", true);
            this.assignButtonInnerTarget.classList.add("btn-disabled", "btn-solid-primary-disabled");
            this.assignButtonInnerTarget.classList.remove("btn-solid-primary");
        }
    }

    openModal() {
        const checkedIds = [...this.element.querySelectorAll('input[name="course_ids[]"]:checked')]
            .map(cb => cb.value);

        this.modalTarget.querySelectorAll('[data-deadline-modal-target="courseRow"]').forEach(row => {
            if (checkedIds.includes(row.dataset.courseId)) {
                row.classList.remove("hidden");
            } else {
                row.classList.add("hidden");
            }
        });

        const container = this.modalTarget.querySelector('[data-deadline-modal-target="courseIdInputs"]');
        if (container) {
            container.innerHTML = checkedIds
                .map(id => `<input type="hidden" name="course_ids[]" value="${id}">`)
                .join('');
        }

        this.modalTarget.style.display = "";
        this.modalTarget.querySelector("button:not([disabled]), input:not([disabled]), select:not([disabled])")?.focus();
    }
}
