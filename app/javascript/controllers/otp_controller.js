import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "submitButton", "hiddenOtp"];

  connect() {
    if (this.inputTargets.length > 0) {
      this.inputTargets[0].focus();
    }
  }

  // updateHiddenOtp() {
  //   const otpValues = this.inputTargets.map((input) => input.value).join("");
  //   this.hiddenOtpTarget.value = otpValues;
  // }

  inputTargetConnected(input) {
    input.addEventListener("input", this.handleInputOrKeyDown.bind(this));
    input.addEventListener("keydown", this.handleInputOrKeyDown.bind(this));
  }

  handleInputOrKeyDown(event) {
    const input = event.target;

    if (event.type === "input") {
      if (input.value.length === 1) {
        const nextInput = this.nextInput(input);
        if (nextInput) nextInput.focus();
      }
      // this.updateHiddenOtp();
    }

    if (event.type === "keydown") {
      if (event.key === "Backspace") {
        if (input.value === "") {
          const previousInput = this.previousInput(input);
          if (previousInput) {
            previousInput.focus();
            // this.updateHiddenOtp();
          }
        } else {
          input.value = "";
          // this.updateHiddenOtp();
        }
      }

      if (event.key === "ArrowLeft") {
        const previousInput = this.previousInput(input);
        if (previousInput) {
          previousInput.focus();
        }
      }

      if (event.key === "ArrowRight") {
        const nextInput = this.nextInput(input);
        if (nextInput) {
          nextInput.focus();
        }
      }
    }

    this.updateButtonState();
  }

  updateButtonState() {
    const allFilled = this.inputTargets.every(
      (input) => input.value.length === 1
    );
    if (allFilled) {
      this.submitButtonTarget.classList.remove("disabled");
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
