import { Controller } from "@hotwired/stimulus";
import Logger from "utils/logger";

export default class extends Controller {
    
  static targets = ["courseCarousalBody", "cardComponent", "prevArrow", "nextArrow"];

  connect() {
    this.currentWindowPosition = 0;
    this.setCardsPerWindow();
    this.updateVisibleCards();

    window.addEventListener("resize", () => {
      const prev = this.cardsPerWindow;
      this.setCardsPerWindow();
      if (this.cardsPerWindow !== prev) {
        this.currentWindowPosition = 0;
        this.updateVisibleCards();
      }
    });
  }

  setCardsPerWindow() {
    const width = window.innerWidth;
    if (width < 640) {
      this.cardsPerWindow = 1; 
    } else if (width < 1024) {
      this.cardsPerWindow = 2; 
    } else {
      this.cardsPerWindow = 4; 
    }
  }

  updateVisibleCards() {
    const start = this.currentWindowPosition * this.cardsPerWindow;
    const end = start + this.cardsPerWindow;
    this.cardComponentTargets.forEach((card, index) => {
      const shouldShow = index >= start && index < end;
  
      if (shouldShow) {
        card.classList.remove("hidden");
  
        card.classList.remove("scale-100", "scale-95", "scale-90", "scale-75");
        card.classList.add("transform", "transition-transform", "duration-500", "ease-out", "scale-90");
  
        void card.offsetWidth;
  
        requestAnimationFrame(() => {
          card.classList.remove("scale-90");
          card.classList.add("scale-100");
        });
      } else {
        card.classList.add("hidden");
      }
    });
  
    this.updateArrowVisibility();
  }

  updateArrowVisibility() {
    if (this.hasPrevArrowTarget) {
      this.prevArrowTarget.classList.toggle("invisible", this.currentWindowPosition === 0);
    }
  
    if (this.hasNextArrowTarget) {
      const totalWindows = Math.ceil(this.cardComponentTargets.length / this.cardsPerWindow);
      this.nextArrowTarget.classList.toggle("invisible", this.currentWindowPosition >= totalWindows - 1);
    }
  }
  
 
  shiftWindowRight() {
    if ((this.currentWindowPosition + 1) * this.cardsPerWindow < this.cardComponentTargets.length) {
      this.currentWindowPosition++;
      this.updateVisibleCards();
    }
  }

  shiftWindowLeft() {
    if (this.currentWindowPosition > 0) {
      this.currentWindowPosition--;
      this.updateVisibleCards();
    }
  }
}
