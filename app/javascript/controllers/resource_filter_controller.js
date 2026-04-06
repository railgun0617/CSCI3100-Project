import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["results"]
  static values = { url: String }

  filter() {
    this.fetchResources()
  }

  search() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.fetchResources()
    }, 300)
  }

  fetchResources() {
    const department = document.getElementById("department-filter").value
    const type = document.getElementById("type-filter").value
    const query = document.getElementById("search-input").value

    fetch(`${this.urlValue}?q=${encodeURIComponent(query)}&tenant_id=${department}&type=${type}`, {
      headers: { "Accept": "application/json" }
    })
      .then(response => response.json())
      .then(data => this.renderResults(data))
  }

  renderResults(data) {
    // data is an array of resources (venues + equipment)
    const container = document.getElementById("results")
    container.querySelector(".grid").innerHTML = data.map(resource => `
      <div class="bg-white rounded-lg shadow p-4">
        <div class="flex justify-between items-start">
          <h2 class="text-xl font-semibold"><a href="/${resource.type}s/${resource.id}" class="text-blue-600 hover:underline">${resource.name}</a></h2>
          <span class="px-2 py-1 text-xs rounded-full ${resource.type === 'venue' ? 'bg-blue-100 text-blue-800' : 'bg-green-100 text-green-800'}">
            ${resource.type}
          </span>
        </div>
        <p class="text-gray-600 mt-2">${resource.description.substring(0, 100)}</p>
        <p class="text-sm text-gray-500 mt-2">Department: ${resource.department}</p>
        <div class="mt-3 flex justify-end">
          <a href="/bookings/new?${resource.type}_id=${resource.id}" class="bg-green-600 text-white px-3 py-1 rounded hover:bg-green-700">Book</a>
        </div>
      </div>
    `).join("")
  }
}