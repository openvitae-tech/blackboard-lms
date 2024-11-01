import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "submitButton", "hiddenOtp"];

  connect() {
    console.log("OTP controller");
  }

  updateHiddenOtp() {
    const otpValues = this.inputTargets.map((input) => input.value).join("");
    this.hiddenOtpTarget.value = otpValues;
  }

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
      this.updateHiddenOtp();
    }

    if (event.type === "keydown" && event.key === "Backspace") {
      if (input.value === "") {
        const previousInput = this.previousInput(input);
        if (previousInput) {
          previousInput.focus();
          this.updateHiddenOtp();
        }
      } else {
        input.value = "";
        this.updateHiddenOtp();
      }
    }

    this.updateButtonState();
  }

  updateButtonState() {
    const allFilled = this.inputTargets.every(
      (input) => input.value.length === 1
    );
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

  nextInput(input) {
    const currentIndex = this.inputTargets.indexOf(input);
    return this.inputTargets[currentIndex + 1];
  }

  previousInput(input) {
    const currentIndex = this.inputTargets.indexOf(input);
    return this.inputTargets[currentIndex - 1];
  }
}
