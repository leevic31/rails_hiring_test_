import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["pollInput", "existingPolls"]

  connect() {
    this.updatePollNumbers();
    this.existingPollsTarget.querySelectorAll('.poll-button').forEach(button => {
      this.addDeleteFunctionality(button);
    });
  }

  addPoll(event) {
    if (event.key === 'Enter') {
      event.preventDefault();
      const pollNumber = this.pollInputTarget.value.trim();
      
      if (pollNumber && !this.isButtonExist(pollNumber)) {
        const button = this.createPollButton(pollNumber);
        this.existingPollsTarget.appendChild(button);
        this.updatePollNumbers();
        this.pollInputTarget.value = '';
      }
    }
  }

  createPollButton(pollNumber) {
    const button = document.createElement('span');
    button.textContent = pollNumber;
    button.className = 'poll-button bg-blue-500 text-white px-2 py-1 rounded m-1 flex items-center';
    button.dataset.pollNumber = pollNumber;

    this.addDeleteFunctionality(button);

    return button;
  }

  addDeleteFunctionality(button) {
    const trashIcon = document.createElement('span');
    trashIcon.textContent = '🗑️';
    trashIcon.className = 'ml-2 cursor-pointer delete-poll';
    trashIcon.onclick = () => {
      this.deletePoll(button);
    };

    button.appendChild(trashIcon);
  }

  deletePoll(button) {
    button.remove();
    this.updatePollNumbers();
  }

  isButtonExist(pollNumber) {
    return this.existingPollsTarget.querySelector(`[data-poll-number='${pollNumber}']`) !== null
  }

  updatePollNumbers() {
    const pollNumbers = Array.from(this.existingPollsTarget.children).map(button => button.dataset.pollNumber);
    const hiddenInput = this.element.querySelector(`input[name^="polling_locations[${this.element.dataset.pollingLocationId}][poll_numbers]"]`);
    if (hiddenInput) {
        hiddenInput.value = pollNumbers.join(',');
    }
  }
}