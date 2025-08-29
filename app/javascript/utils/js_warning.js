function hideJsWarning() {
    const jsWarning = document.getElementById("js-warning");
    if (jsWarning) jsWarning.style.display = "none";
  }
  
  ["DOMContentLoaded", "turbo:load", "turbo:render", "turbo:before-render", "turbo:before-cache"]
    .forEach(event => document.addEventListener(event, hideJsWarning));
  