import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "submitButton", "timer", "resendOtp"];

  connect() {
    if (this.inputTargets.length > 0) {
      this.inputTargets[0].focus();
    }
    this.startTimer(120); 

  }
  startTimer(duration) {
    let timer = duration;
    this.resendOtpTarget.classList.add("disabled"); 

    if (this.timerInterval) {
      clearInterval(this.timerInterval); 
    }

    this.timerInterval = setInterval(() => {
      const minutes = Math.floor(timer / 60);
      const seconds = timer % 60;
      this.timerTarget.textContent = `${minutes}:${seconds < 10 ? "0" : ""}${seconds} min`;

      if (timer === 0) {
        clearInterval(this.timerInterval);
        this.resendOtpTarget.classList.remove("disabled"); 
      }

      timer--;
    }, 1000);
  }

  resendOtp(event) {
    event.preventDefault();
    this.startTimer(120); 
    this.resendOtpTarget.classList.add("disabled"); 
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
    }

    if (event.type === "keydown") {
      if (event.key === "Backspace") {
        if (input.value === "") {
          const previousInput = this.previousInput(input);
          if (previousInput) {
            previousInput.focus();
          }
        } else {
          input.value = "";
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
