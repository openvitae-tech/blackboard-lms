export function toggleButtonState(type) {
  const submitButton = document.getElementById("submit-button");
  const addNewButton = document.getElementById("add-new-lang");

  if(type === "disabled") {
    submitButton.classList.add("disabled");
    addNewButton.classList.add("disabled");
  } else {
    submitButton.classList.remove("disabled");
    addNewButton.classList.remove("disabled");
  }
}
