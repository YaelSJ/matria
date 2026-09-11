class AddCaseEventsAndPendingReview < ActiveRecord::Migration[8.1]
  def change
    change_column_default :cases, :status, from: "draft", to: "draft"

    create_table :case_events do |t|
      t.references :case, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :event_type, null: false
      t.string :from_status
      t.string :to_status, null: false
      t.text :comment
      t.timestamps
    end

    add_index :case_events, [:case_id, :created_at]
  end
end
