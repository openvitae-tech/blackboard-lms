import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
     "progressBar",
     "welcomeScreen",
     "step1Screen", 
     "step2Screen", 
     "step3Screen", 
     "step4Screen", 
     "otherLanguageField",
    ];

  nextScreen(event) {
    event.preventDefault();
    
    let currentScreen = event.currentTarget.dataset.current;
    let nextScreen = event.currentTarget.dataset.next;

    this[currentScreen + "Target"].classList.add("hidden");
    this[nextScreen + "Target"].classList.remove("hidden");
    this.updateProgress();
  }

  previousScreen(event) {
    event.preventDefault();

    let currentScreen = event.currentTarget.dataset.current;
    let previousScreen = event.currentTarget.dataset.previous;

    this[currentScreen + "Target"].classList.add("hidden");
    this[previousScreen + "Target"].classList.remove("hidden");
    this.updateProgress();
  }
  
  showOtherLanguageField(event) {
    const selectedValue = event.target.value;
    if (selectedValue === "Others") {
      this.otherLanguageFieldTarget.classList.remove("hidden");
    } else {
      this.otherLanguageFieldTarget.classList.add("hidden");
    }
    
    this.radioDotsTargets.forEach((dot) => {
      dot.classList.add("hidden"); 
    });
    const selectedRadioButton = event.target;

    if (Array.isArray(this.radioButtonsTargets) || this.radioButtonsTargets instanceof NodeList) {
      const selectedIndex = Array.from(this.radioButtonsTargets).indexOf(selectedRadioButton);
  
      const selectedDot = this.radioDotsTargets[selectedIndex];
      if (selectedDot) {
        selectedDot.classList.remove("hidden");
      }
    } else {
      //
    }

  }

  updateProgress() {
    let progress = 0;

    if (this.basicDetailsScreen1Target.classList.contains("hidden")) {
      progress = 0;
    }
    if (!this.basicDetailsScreen1Target.classList.contains("hidden")) {
      progress = 25;
    }
    if (!this.basicDetailsScreen2Target.classList.contains("hidden")) {
      progress = 50;
    }
    if (!this.preferedLanguageScreenTarget.classList.contains("hidden")) {
      progress = 75;
    }
    if (!this.setPasswordScreenTarget.classList.contains("hidden")) {
      progress = 100;
    }

    this.progressBarTarget.style.width = `${progress}%`;
  }
}