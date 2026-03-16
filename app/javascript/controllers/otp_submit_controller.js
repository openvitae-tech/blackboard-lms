import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "submitButton", "hiddenOtp", "container", "innerButton", "phoneInput"];

  connect() {
    if (this.hasContainerTarget) {
      this.containerTarget.classList.remove("border", "border-danger");
    }

    if (this.inputTargets.length > 0) {
      this.inputTargets[0].focus();
    }
    this.inputTargets.forEach(input => {
      input.addEventListener('input', e => {
        e.target.value = e.target.value.replace(/\D/g, '').trim();
      });
      input.addEventListener("paste", this.handlePaste.bind(this));
    });

    this.updateButtonState();
  }

  updateHiddenOtp() {
    const otpValues = this.inputTargets.map((input) => input.value).join("");
    if (this.hasHiddenOtpTarget) {
      this.hiddenOtpTarget.value = otpValues;
    }
    this.updateButtonState();
  }

  inputTargetConnected(input) {
    input.addEventListener("input", this.handleInputOrKeyDown.bind(this));
    input.addEventListener("keydown", this.handleInputOrKeyDown.bind(this));
  }

  handleInputOrKeyDown(event) {
    const input = event.target;

    if (event.type === "input") {
      if (/^\d$/.test(input.value)) {
        const nextInput = this.nextInput(input);
        if (nextInput) nextInput.focus();
      } else {
        input.value = "";
      }
      this.updateHiddenOtp();
    }

    if (event.type === "keydown") {
      if (event.key === "Backspace") {
        if (input.value === "") {
          const previousInput = this.previousInput(input);
          if (previousInput) previousInput.focus();
        } else {
          input.value = "";
        }
        this.updateHiddenOtp();
      }

      if (event.key === "ArrowLeft") {
        const previousInput = this.previousInput(input);
        if (previousInput) previousInput.focus();
      }

      if (event.key === "ArrowRight") {
        const nextInput = this.nextInput(input);
        if (nextInput) nextInput.focus();
      }
    }

    this.updateButtonState();
  }

  handlePaste(event) {
    event.preventDefault();

    const pastedData = event.clipboardData.getData("text").replace(/\D/g, "");
    const digits = pastedData.slice(0, this.inputTargets.length).split("");

    digits.forEach((digit, index) => {
      const input = this.inputTargets[index];
      if (input) input.value = digit;
    });

    this.updateHiddenOtp();

    const nextEmpty = this.inputTargets.find((input) => input.value === "");
    if (nextEmpty) nextEmpty.focus();
  }

  checkPhoneInput() {
    this.updateButtonState();
  }

  updateButtonState() {
    let allFilled = false;
    if (this.hasPhoneInputTarget) {
      const phoneField = document.querySelector("input[name='user[phone]']");
      allFilled = phoneField && phoneField.value.trim().length > 0;
    } else if (this.hasInputTarget) {
      allFilled = this.inputTargets.length === 4 && this.inputTargets.every((input) => input.value.length === 1);
    }
    if (this.hasSubmitButtonTarget) {
      if (allFilled) {
        this.submitButtonTarget.removeAttribute("disabled");
        this.submitButtonTarget.classList.remove("cursor-not-allowed", "pointer-events-none");
        this.submitButtonTarget.classList.add("cursor-pointer");
        this.innerButtonTarget.classList.remove("btn-disabled", "btn-solid-primary-disabled");
        this.innerButtonTarget.classList.add("btn-solid-primary");      
      } else {
        this.submitButtonTarget.setAttribute("disabled", "true");
        this.submitButtonTarget.classList.add("cursor-not-allowed", "pointer-events-none");
        this.submitButtonTarget.classList.remove("cursor-pointer");
        this.innerButtonTarget.classList.remove("btn-solid-primary");
        this.innerButtonTarget.classList.add("btn-disabled", "btn-solid-primary-disabled");      }
    }
  }

  nextInput(input) {
    const currentIndex = this.inputTargets.indexOf(input);
    return this.inputTargets[currentIndex + 1];
  }

  previousInput(input) {
    const currentIndex = this.inputTargets.indexOf(input);
    return this.inputTargets[currentIndex - 1];
  }
}
