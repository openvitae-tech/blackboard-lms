import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["hiddenOtp"]

  handleOtp() {
    const otp1 = this.element.querySelector(".input-text-otp:nth-child(1)").value;
    const otp2 = this.element.querySelector(".input-text-otp:nth-child(2)").value;
    const otp3 = this.element.querySelector(".input-text-otp:nth-child(3)").value;
    const otp4 = this.element.querySelector(".input-text-otp:nth-child(4)").value;

    const otp = [otp1, otp2, otp3, otp4].join('');

    this.hiddenOtpTarget.value = otp
  }
}
