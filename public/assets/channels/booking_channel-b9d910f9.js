import consumer from "./consumer";

class BookingRealtime {
  constructor(currentUserId, currentUserEmail) {
    this.currentUserId = currentUserId;
    this.currentUserEmail = currentUserEmail;
    this.subscription = null;
    this.init();
  }

  init() {
    this.subscription = consumer.subscriptions.create("BookingChannel", {
      connected: () => console.log("Connected to booking channel"),
      disconnected: () => console.log("Disconnected"),
      received: (data) => this.handleMessage(data),
    });
  }

  handleMessage(data) {
    switch(data.type) {
      case 'slot_unavailable':
        // Update venue time slot to unavailable
        this.updateVenueSlot(data.resource_id, data.start_time, data.end_time, 'unavailable');
        break;
      case 'quantity_update':
        // Update equipment time slot remain quantity and status
        this.updateEquipmentSlot(data.resource_id, data.start_time, data.end_time, data.remaining_quantity);
        break;
      case 'book_success':
        if (this.onBookSuccess) this.onBookSuccess(data);
        break;
      case 'book_failed':
        if (this.onBookFailed) this.onBookFailed(data);
        break;
    }
  }

  updateVenueSlot(resourceId, startTime, endTime, status) {
    const selector = `.time-slot[data-resource-id="${resourceId}"][data-start-time="${startTime}"]`;
    const slotElement = document.querySelector(selector);
    if (slotElement) {
      slotElement.classList.add('booked');
      const button = slotElement.querySelector('button');
      if (button) {
        button.disabled = true;
        button.textContent = 'Booked';
      }
    }
  }

  updateEquipmentSlot(resourceId, startTime, endTime, remaining) {
    const selector = `.time-slot[data-resource-id="${resourceId}"][data-start-time="${startTime}"]`;
    const slotElement = document.querySelector(selector);
    if (slotElement) {
      const button = slotElement.querySelector('button');
      const select = slotElement.querySelector('.quantity-select');
      if (remaining <= 0) {
        if (button) button.disabled = true;
        if (select) select.disabled = true;
      } else {
        // 更新最大可选数量
        if (select) {
          select.innerHTML = '';
          for (let i = 1; i <= remaining; i++) {
            const option = document.createElement('option');
            option.value = i;
            option.textContent = i;
            select.appendChild(option);
          }
          select.disabled = false;
        }
        if (button) button.disabled = false;
      }
    }
  }

  showToast(message, type) {
    alert(message);
  }
}

export default BookingRealtime;