class RemoveCaseFileKind < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL.squish
      UPDATE case_files
      SET file_type = kind
      WHERE (file_type IS NULL OR file_type = '') AND kind IS NOT NULL
    SQL

    remove_column :case_files, :kind
  end

  def down
    add_column :case_files, :kind, :string, null: false, default: "document"
    execute <<~SQL.squish
      UPDATE case_files
      SET kind = file_type
      WHERE file_type IS NOT NULL
    SQL
  end
end
