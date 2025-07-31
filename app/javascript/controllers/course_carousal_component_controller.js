import { Controller } from "@hotwired/stimulus";
import Logger from "utils/logger";

export default class extends Controller {
    
    static targets = ["courseCarousalBody", "cardComponent", "prevArrow", "nextArrow"];

  connect() {
    this.currentPage = 0;
    this.setCardsPerPage();
    this.updateVisibleCards();

    window.addEventListener("resize", () => {
      const prev = this.cardsPerPage;
      this.setCardsPerPage();
      if (this.cardsPerPage !== prev) {
        this.currentPage = 0;
        this.updateVisibleCards();
      }
    });
  }

  setCardsPerPage() {
    const width = window.innerWidth;
    if (width < 640) {
      this.cardsPerPage = 1; 
    } else if (width < 1024) {
      this.cardsPerPage = 2; 
    } else {
      this.cardsPerPage = 4; 
    }
  }

  updateVisibleCards() {
    const start = this.currentPage * this.cardsPerPage;
    const end = start + this.cardsPerPage;

    this. cardComponentTargets.forEach((card, index) => {
      card.classList.toggle("hidden", index < start || index >= end);
    });

    this.updateArrowVisibility();
  }

  updateArrowVisibility() {
    if (this.hasPrevArrowTarget) {
      this.prevArrowTarget.classList.toggle("invisible", this.currentPage === 0);
    }
  
    if (this.hasNextArrowTarget) {
      const totalPages = Math.ceil(this.cardComponentTargets.length / this.cardsPerPage);
      this.nextArrowTarget.classList.toggle("invisible", this.currentPage >= totalPages - 1);
    }
  }
  
 
  loadNextPage() {
    if ((this.currentPage + 1) * this.cardsPerPage < this. cardComponentTargets.length) {
      this.currentPage++;
      this.updateVisibleCards();
    }
  }

  loadPrevPage() {
    if (this.currentPage > 0) {
      this.currentPage--;
      this.updateVisibleCards();
    }
  }
}
