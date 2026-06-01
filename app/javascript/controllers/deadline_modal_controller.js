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
        this.isOpen = false;
        this.boundHandleSubmitEnd = this.handleSubmitEnd.bind(this);
        this.boundHandleKeydown = this.handleKeydown.bind(this);
        this.element.addEventListener("turbo:submit-end", this.boundHandleSubmitEnd);
        document.addEventListener("keydown", this.boundHandleKeydown);
    }

    open() {
        this.isOpen = true;
        const wrapper = this.element.closest(".modal-wrapper");
        if (wrapper) wrapper.style.display = "";
        this.element
            .querySelector("button:not([disabled]), input:not([disabled]), select:not([disabled])")
            ?.focus();
    }

    disconnect() {
        this.element.removeEventListener("turbo:submit-end", this.boundHandleSubmitEnd);
        document.removeEventListener("keydown", this.boundHandleKeydown);
    }

    handleSubmitEnd(event) {
        if (event.detail.success) this.close();
    }

    handleKeydown(event) {
        if (event.key !== "Escape" || !this.isOpen) return;
        this.cancel();
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

    propagateApplyAllDate(event) {
        const dateValue = event.target.value;
        if (!dateValue) return;

        this.durationSelectTargets.forEach(select => {
            const row = select.closest('[data-deadline-modal-target="courseRow"]');
            if (row.classList.contains("hidden") || select.value !== "custom") return;

            const datePickerEl = row.querySelector('[data-controller~="date-picker"]');
            datePickerEl?.dispatchEvent(
                new CustomEvent('date-picker:set-value', { detail: { value: dateValue }, bubbles: false })
            );
        });
    }

    resetApplyAll() {
        this.applyAllSelectTarget.value = "";
        this.applyAllCustomDateTarget.classList.add("hidden");
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
        this.isOpen = false;
        const wrapper = this.element.closest(".modal-wrapper");
        if (wrapper) wrapper.style.display = "none";
    }
}
