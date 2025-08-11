import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "submitButton", "hiddenOtp"];

  connect() {
    if (this.inputTargets.length > 0) {
      this.inputTargets[0].focus();
    }
    this.inputTargets.forEach(input => {
      input.addEventListener('input', e => {
        e.target.value = e.target.value.replace(/\D/g, '').trim();
      });
      input.addEventListener("paste", this.handlePaste.bind(this));
    });
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

  updateButtonState() {
    const allFilled = this.inputTargets.every((input) => input.value.length === 1);
    if (this.hasSubmitButtonTarget) {
      if (allFilled) {
        this.submitButtonTarget.classList.remove("btn-default");
        this.submitButtonTarget.classList.add("btn-primary");
        this.submitButtonTarget.removeAttribute("disabled");
      } else {
        this.submitButtonTarget.classList.remove("btn-primary");
        this.submitButtonTarget.classList.add("btn-default");
        this.submitButtonTarget.setAttribute("disabled", "true");
      }
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
