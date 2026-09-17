# Shared by the registration form and server validation to keep stored names identical.
class MexicanLocations
  CATALOG = JSON.parse(Rails.root.join("config/data/mexico_locations.json").read).freeze
  COUNTRY = CATALOG.fetch("country").freeze
  OPTIONS = CATALOG.fetch("states").to_h do |state|
    [state.fetch("name"), state.fetch("municipalities").map { |municipality| municipality.fetch("name") }.freeze]
  end.freeze

  def self.states
    OPTIONS.keys
  end

  def self.municipalities(state)
    OPTIONS.fetch(state, [])
  end

  def self.options
    OPTIONS
  end
end
