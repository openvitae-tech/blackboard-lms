import { Controller } from "@hotwired/stimulus";
import Logger from "utils/logger";

export default class extends Controller {
  static targets = ["source", "copyButton"];

  async copyToClipboard() {
    try {
      await navigator.clipboard.writeText(this.sourceTarget.value);

      const button = this.copyButtonTarget;
      const originalText = button.textContent;
      button.textContent = "Copied!";

      setTimeout(() => {
        button.textContent = originalText;
      }, 2000);
    } catch (error) {
      Logger.error(error);
    }
  }
}
