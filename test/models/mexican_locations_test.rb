require "test_helper"

class MexicanLocationsTest < ActiveSupport::TestCase
  test "catalog contains all entries from the August 2026 source" do
    assert_equal 32, MexicanLocations.states.size
    assert_equal 2478, MexicanLocations.options.values.sum(&:size)
    assert_equal 16, MexicanLocations.municipalities("Ciudad de México").size
    assert_equal 125, MexicanLocations.municipalities("Estado de México").size
    assert_equal 570, MexicanLocations.municipalities("Oaxaca").size
    MexicanLocations::CATALOG.fetch("states").each do |state|
      codes = state.fetch("municipalities").map { |municipality| municipality.fetch("code") }
      assert_equal codes.uniq, codes
      names = state.fetch("municipalities").map { |municipality| municipality.fetch("name") }
      assert_equal names.uniq, names
    end
  end

  test "names retain accents and conventional capitalization" do
    assert_includes MexicanLocations.municipalities("Ciudad de México"), "Coyoacán"
    assert_includes MexicanLocations.municipalities("Ciudad de México"), "Azcapotzalco"
    assert_includes MexicanLocations.municipalities("Ciudad de México"), "Cuajimalpa de Morelos"
    assert_includes MexicanLocations.municipalities("Estado de México"), "Ecatepec de Morelos"
    assert_empty MexicanLocations.municipalities("Unknown")
  end

  test "registration rejects unknown country state and noncanonical spelling" do
    [
      ["Otro país", "Ciudad de México", "Coyoacán", :user_country],
      ["México", "CDMX", "Coyoacán", :state],
      ["México", "Ciudad de México", "coyoacan", :city],
      ["México", "Estado de México", "Coyoacán", :city]
    ].each do |country, state, city, attribute|
      user = User.new(email: "catalog@example.com", password: "password123",
                      user_country: country, state: state, city: city,
                      require_registration_location: true)
      assert_not user.valid?
      assert user.errors[attribute].present?, "Expected an error for #{attribute}"
    end
  end
end
