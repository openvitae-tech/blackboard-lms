import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["star", "input", "form"];
  static values = { url: String };

  headers = {
    Accept: "text/html",
  };

  initialize() {
    this.selectedRating = 0;
  }

  select(event) {
    const clickedValue = parseInt(
      event.currentTarget.dataset.lessonRatingValue
    );

    if (this.selectedRating === clickedValue) {
      this.updateStars(clickedValue - 1);
    } else {
      this.updateStars(clickedValue);
    }
  }

  updateStars(value) {
    this.starTargets.forEach((star, index) => {
      const svg = star.querySelector("svg");
      const smileySvg = star.querySelectorAll("svg")[1];

      if (smileySvg) {
        if (index + 1 === value) {
          smileySvg.classList.add("fill-gold");
        } else {
          smileySvg.classList.remove("fill-gold");
        }
      }

      if (index < value) {
        svg.classList.add("fill-secondary");
      } else {
        svg.classList.remove("fill-secondary");
      }
    });

    this.selectedRating = value;

    if (this.hasInputTarget) {
      this.inputTarget.value = this.selectedRating;
    }
  }

  async completeAndRate(event) {
    event.preventDefault();

    await fetch(this.urlValue, {
      method: "GET",
      headers: this.headers,
    })
      .then((response) => response.text())
      .then((html) => Turbo.renderStreamMessage(html));
  }

  handleSubmit() {
    const input = document.getElementsByName("time_spent");

    input[0].form.submit();
  }
}
