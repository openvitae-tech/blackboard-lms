import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["step", "nextButton", "prevButton","cancelButton", "submitButton", "indicator"]
  static values = { currentStep: Number }

  connect() {
    this.currentStepValue = 1
    this.updateView()
  }

  next() {
    this.currentStepValue++
    this.updateView()
  }

  previous() {
    this.currentStepValue--
    this.updateView()
  }

  updateView() {
    this.stepTargets.forEach((step, index) => {
      step.classList.toggle("hidden", index + 1 !== this.currentStepValue)
    })

    this.cancelButtonTarget.classList.toggle("hidden", this.currentStepValue  > 1)

    this.prevButtonTarget.classList.toggle("hidden", this.currentStepValue == 1)
    this.nextButtonTarget.classList.toggle("hidden", this.currentStepValue === this.stepTargets.length)
    this.submitButtonTarget.classList.toggle("hidden", this.currentStepValue !== this.stepTargets.length)

    this.updateIndicators()
  }

  updateIndicators() {
    this.indicatorTargets.forEach((dot, index) => {
      const stepIndex = index + 1

      dot.classList.remove(
        "border-2",
        "border-primary",
        "bg-secondary",
        "bg-primary-light-100"
      )

      if (stepIndex === this.currentStepValue) {
        dot.classList.add(
          "border-2",
          "border-primary",
          "bg-primary-light-100"
        )
      } else if (stepIndex < this.currentStepValue) {
        dot.classList.add("bg-secondary")
      } else {
        dot.classList.add("bg-primary-light-100")
      }

    })
  }

}
