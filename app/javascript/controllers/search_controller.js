// Handles debounced search and displays results (requires a backend endpoint /venues/search.json).
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "results"]

  connect() {
    this.debounceTimer = null
  }

  search(event) {
    clearTimeout(this.debounceTimer)
    const query = event.target.value
    if (query.length < 2) {
      this.clearResults()
      return
    }
    this.debounceTimer = setTimeout(() => {
      this.fetchResults(query)
    }, 300)
  }

  fetchResults(query) {
    fetch(`/venues/search.json?q=${encodeURIComponent(query)}`, {
      headers: { "Accept": "application/json" }
    })
      .then(response => response.json())
      .then(data => this.renderResults(data))
      .catch(error => console.error("Search failed", error))
  }

  renderResults(venues) {
    this.resultsTarget.innerHTML = venues.map(v => `
      <div class="p-2 hover:bg-gray-100 cursor-pointer" data-action="click->search#select" data-venue-id="${v.id}">
        ${v.name}
      </div>
    `).join("")
  }

  select(event) {
    const venueId = event.currentTarget.dataset.venueId
    window.location.href = `/venues/${venueId}`
  }

  clearResults() {
    this.resultsTarget.innerHTML = ""
  }
}