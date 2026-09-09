class AddRiskLevelToCases < ActiveRecord::Migration[8.1]
  def change
    add_column :cases, :risk_level, :string
  end
end
