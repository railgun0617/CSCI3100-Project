import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { lat: Number, lng: Number }

  connect() {
    if (this.hasLatValue && this.hasLngValue) {
      this.initMap()
    } else {
      this.element.innerHTML = "<p class='text-gray-500'>Location not available</p>"
    }
  }

  initMap() {
    // For now, display coordinates. Later replace with Google Maps.
    this.element.innerHTML = `<p>Lat: ${this.latValue}, Lng: ${this.lngValue}</p>`
  }
}