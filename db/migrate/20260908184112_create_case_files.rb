class CreateCaseFiles < ActiveRecord::Migration[8.1]
  def change
    create_table :case_files do |t|
      t.string :document_number
      t.string :file_type
      t.string :title
      t.string :state
      t.references :case, null: false, foreign_key: true

      t.timestamps
    end
  end
end
