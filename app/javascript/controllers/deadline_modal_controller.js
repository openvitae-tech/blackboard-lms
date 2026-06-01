import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    static targets = [
        "applyAllSelect",
        "applyAllCustomDate",
        "courseRow",
        "durationSelect",
        "customDateWrapper",
        "customDateInput"
    ];

    connect() {
        this.boundHandleSubmitEnd = this.handleSubmitEnd.bind(this);
        this.element.addEventListener("turbo:submit-end", this.boundHandleSubmitEnd);
    }

    disconnect() {
        this.element.removeEventListener("turbo:submit-end", this.boundHandleSubmitEnd);
    }

    handleSubmitEnd(event) {
        if (event.detail.success) this.close();
    }

    toggleApplyAllCustomDate(event) {
        const duration = event.target.value;

        if (duration === "custom") {
            this.applyAllCustomDateTarget.classList.remove("hidden");
            const icon = this.applyAllCustomDateTarget.querySelector('[data-action*="openDatePicker"]');
            requestAnimationFrame(() => icon?.click());
        } else {
            this.applyAllCustomDateTarget.classList.add("hidden");
        }

        this.durationSelectTargets.forEach(select => {
            const row = select.closest('[data-deadline-modal-target="courseRow"]');
            if (row.classList.contains("hidden")) return;

            select.value = duration;

            const wrapper = row.querySelector('[data-deadline-modal-target="customDateWrapper"]');
            if (duration === "custom") {
                wrapper.classList.remove("hidden");
            } else {
                wrapper.classList.add("hidden");
            }
        });
    }

    propagateApplyAllDate() {
        const dateValue = this.applyAllCustomDateTarget
            .querySelector('[data-date-picker-target="dateSelector"]')?.value;
        if (!dateValue) return;

        this.durationSelectTargets.forEach(select => {
            const row = select.closest('[data-deadline-modal-target="courseRow"]');
            if (row.classList.contains("hidden") || select.value !== "custom") return;

            const input = row.querySelector('[data-date-picker-target="dateSelector"]');
            if (input) input.value = dateValue;
        });
    }

    toggleCustomDate(event) {
        this.applyAllSelectTarget.value = "";
        this.applyAllCustomDateTarget.classList.add("hidden");

        const row = event.target.closest('[data-deadline-modal-target="courseRow"]');
        const wrapper = row.querySelector('[data-deadline-modal-target="customDateWrapper"]');
        if (event.target.value === "custom") {
            wrapper.classList.remove("hidden");
            const icon = wrapper.querySelector('[data-action*="openDatePicker"]');
            requestAnimationFrame(() => icon?.click());
        } else {
            wrapper.classList.add("hidden");
        }
    }

    cancel() {
        this.applyAllSelectTarget.value = "";
        this.applyAllCustomDateTarget.classList.add("hidden");

        this.durationSelectTargets.forEach(select => {
            select.value = "";
            const row = select.closest('[data-deadline-modal-target="courseRow"]');
            row.querySelector('[data-deadline-modal-target="customDateWrapper"]')
               ?.classList.add("hidden");
        });

        this.close();
    }

    close() {
        const wrapper = this.element.closest(".modal-wrapper");
        if (wrapper) wrapper.style.display = "none";
    }
}
