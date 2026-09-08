class CreateCases < ActiveRecord::Migration[8.1]
  def change
    create_table :cases do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :representative, null: true, foreign_key: { to_table: :users }
      t.boolean :consent
      t.text :summary

      t.timestamps
    end
  end
end
