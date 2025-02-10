export default class Logger {
  static error(...args) {
    if (
      document.head.querySelector("meta[name=rails_env]").content ===
      "development"
    ) {
      console.error(...args);
    } else {
      console.error("Something went wrong");
    }
  }
}
