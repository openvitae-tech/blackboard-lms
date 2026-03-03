import { Controller } from "@hotwired/stimulus"
import Swiper from "swiper"

export default class extends Controller {
  static targets = ["container", "next", "prev"]
  static values = {isLoop: Boolean, enableInSmallDevices: Boolean}

  connect() {
    this.swiper = new Swiper(this.containerTarget, {
      loop: this.isLoopValue,
      centeredSlides: true,
      slidesPerView: "auto",
      spaceBetween: 16,
      grabCursor: true,
      
      speed: 600,

      navigation: {
        nextEl: this.nextTarget,
        prevEl: this.prevTarget,
      },
      breakpoints: {
        0: {
          slidesPerView: 1.4,
          spaceBetween: this.isLoopValue ? 0 : 20,
          centeredSlides: this.isLoopValue,
        },
        768: {
          slidesPerView: 'auto',
          spaceBetween: 20,
          centeredSlides: false,
          loop: false,
        }
      },
    })
  }

  disconnect() {
    if (this.swiper) this.swiper.destroy()
  }
}