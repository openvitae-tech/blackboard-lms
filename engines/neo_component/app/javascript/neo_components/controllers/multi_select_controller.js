import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "chip",
    "chipsContainer",
    "option",
    "hiddenInput",
    "placeholder",
    "dropdown",
  ];
  static values = { disabled: Boolean };

  connect() {
    this._closeHandler = this._handleOutsideClick.bind(this);
    document.addEventListener("click", this._closeHandler);
  }

  disconnect() {
    document.removeEventListener("click", this._closeHandler);
  }

  toggleDropdown() {
    if (this.disabledValue) return;
    this.dropdownTarget.classList.toggle("hidden");
  }

  selectOption(event) {
    event.stopPropagation();
    this._activate(event.currentTarget.dataset.value);
  }

  removeChip(event) {
    event.stopPropagation();
    this._deactivate(event.currentTarget.dataset.value);
  }

  _activate(value) {
    this._chip(value)?.classList.remove("hidden");
    this._option(value)?.classList.add("hidden");
    const input = this._hiddenInput(value);
    if (input) input.disabled = false;
    this._syncChipsContainer();
    this._syncPlaceholder();
  }

  _deactivate(value) {
    this._chip(value)?.classList.add("hidden");
    this._option(value)?.classList.remove("hidden");
    const input = this._hiddenInput(value);
    if (input) input.disabled = true;
    this._syncChipsContainer();
    this._syncPlaceholder();
  }

  _chip(value) {
    return this.chipTargets.find((el) => el.dataset.value == value);
  }

  _option(value) {
    return this.optionTargets.find((el) => el.dataset.value == value);
  }

  _hiddenInput(value) {
    return this.hiddenInputTargets.find((el) => el.dataset.value == value);
  }

  _syncChipsContainer() {
    if (!this.hasChipsContainerTarget) return;
    const hasSelected = this.chipTargets.some(
      (el) => !el.classList.contains("hidden")
    );
    this.chipsContainerTarget.classList.toggle("hidden", !hasSelected);
  }

  _syncPlaceholder() {
    if (!this.hasPlaceholderTarget) return;
    const hasSelected = this.chipTargets.some(
      (el) => !el.classList.contains("hidden")
    );
    this.placeholderTarget.classList.toggle("hidden", hasSelected);
  }

  _handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.dropdownTarget.classList.add("hidden");
    }
  }
}
