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
      if (index < value) {
        star.classList.add("icon-star");
        star.classList.remove("icon-star-transparent");
      } else {
        star.classList.add("icon-star-transparent");
        star.classList.remove("icon-star");
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
