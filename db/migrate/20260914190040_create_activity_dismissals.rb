class CreateActivityDismissals < ActiveRecord::Migration[8.1]
  def change
    create_table :activity_dismissals do |t|
      t.references :user, null: false, foreign_key: true
      t.references :case_event, null: false, foreign_key: true

      t.timestamps
    end

    add_index :activity_dismissals,
              [:user_id, :case_event_id],
              unique: true
  end
end
