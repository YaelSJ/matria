import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["country", "state", "city"]
  static values = { catalog: Object }

  connect() {
    const state = this.stateTarget.value
    const city = this.cityTarget.value
    this.updateStates(state)
    this.updateCities(city)
  }

  countryChanged() {
    this.updateStates()
    this.updateCities()
  }

  stateChanged() {
    this.updateCities()
  }

  updateStates(selected = "") {
    const states = this.countryTarget.value === "México" ? Object.keys(this.catalogValue) : []
    this.replaceOptions(this.stateTarget, states, "Selecciona tu estado", selected)
  }

  updateCities(selected = "") {
    const cities = this.countryTarget.value === "México" && Object.hasOwn(this.catalogValue, this.stateTarget.value)
      ? this.catalogValue[this.stateTarget.value]
      : []
    this.replaceOptions(this.cityTarget, cities, "Selecciona tu municipio o alcaldía", selected)
  }

  replaceOptions(select, values, prompt, selected) {
    const sorted = [...values].sort((a, b) => a.localeCompare(b, "es"))
    select.replaceChildren(new Option(prompt, ""), ...sorted.map(value => new Option(value, value)))
    select.value = values.includes(selected) ? selected : ""
    select.disabled = values.length === 0
  }
}
