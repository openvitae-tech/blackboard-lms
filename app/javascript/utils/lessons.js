export function toggleButtonState({ type, pendingCount }) {
  const submitButton = document.getElementById("submit-button");

  type === "disabled" && submitButton.classList.add("disabled");

  pendingCount === 0 && submitButton.classList.remove("disabled");
}
