import { Controller } from "@hotwired/stimulus"

const ACTIVE_CLASSES    = ["bg-primary-light-100", "border-2", "border-primary", "text-primary"]
const COMPLETED_CLASSES = ["bg-primary-light-100", "border", "border-slate-grey-light", "text-slate-grey-50"]
const UPCOMING_CLASSES  = ["bg-white", "border", "border-slate-grey-light", "text-slate-grey-50"]
const ALL_STATE_CLASSES = [...new Set([...ACTIVE_CLASSES, ...COMPLETED_CLASSES, ...UPCOMING_CLASSES])]

export default class extends Controller {
  static targets = ["indicator", "panel"]
  static values = { currentStep: Number }

  connect() {
    this.activeStep = this.currentStepValue
    this.updateView()
  }

  goToStep({ params: { step } }) {
    if (step > this.currentStepValue) return
    this.activeStep = step
    this.updateView()
  }

  updateView() {
    this.panelTargets.forEach((panel, index) => {
      panel.classList.toggle("hidden", index !== this.activeStep)
    })

    this.indicatorTargets.forEach((indicator, index) => {
      const accessible = index <= this.currentStepValue
      indicator.classList.toggle("cursor-pointer", accessible)
      indicator.classList.toggle("cursor-default", !accessible)

      indicator.classList.remove(...ALL_STATE_CLASSES)

      if (index === this.activeStep) {
        indicator.classList.add(...ACTIVE_CLASSES)
      } else if (index < this.activeStep) {
        indicator.classList.add(...COMPLETED_CLASSES)
      } else {
        indicator.classList.add(...UPCOMING_CLASSES)
      }
    })
  }
}
