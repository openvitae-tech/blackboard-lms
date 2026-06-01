import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = ["assignButton", "assignButtonInner"];
    static outlets = ["deadline-modal"];

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

        this.deadlineModalOutlet.element.querySelectorAll('[data-deadline-modal-target="courseRow"]').forEach(row => {
            if (checkedIds.includes(row.dataset.courseId)) {
                row.classList.remove("hidden");
            } else {
                row.classList.add("hidden");
            }
        });

        const container = this.deadlineModalOutlet.element.querySelector('[data-deadline-modal-target="courseIdInputs"]');
        if (container) {
            container.replaceChildren(...checkedIds.map(id => {
                const input = document.createElement('input');
                input.type = 'hidden';
                input.name = 'course_ids[]';
                input.setAttribute('value', id);
                return input;
            }));
        }

        this.deadlineModalOutlet.open();
    }
}
