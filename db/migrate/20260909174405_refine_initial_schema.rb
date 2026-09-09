class RefineInitialSchema < ActiveRecord::Migration[8.1]
  def change
    # 1. Renombrar tipo en users sin perder datos
    rename_column :users, :user_contry, :country

    # 2. Agregar birth_date y respaldar los datos de age
    add_column :users, :birth_date, :date

    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE users
          SET birth_date = (CURRENT_DATE - (age || ' years')::interval)::date
          WHERE age IS NOT NULL;
        SQL
      end
    end

    remove_column :users, :age, :integer

    # 3. Roles con valores por defecto y null: false
    change_column_null :users, :role, false, "user"
    change_column_default :users, :role, from: nil, to: "user"

    # 4. Control de estado y consentimiento en cases
    add_column :cases, :status, :string, default: "pending", null: false
    change_column_null :cases, :consent, false, false
    change_column_default :cases, :consent, from: nil, to: false

    # 5. Índice compuesto para optimizar chat
    add_index :messages, [:chat_id, :created_at]
  end
end
