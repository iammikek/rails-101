class CreateCatalogTables < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.timestamps
    end
    add_index :users, :email, unique: true

    create_table :categories do |t|
      t.string :name, null: false, limit: 100
      t.text :description
      t.timestamps
    end
    add_index :categories, :name, unique: true

    create_table :items do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :price, precision: 10, scale: 2, null: false
      t.references :category, null: true, foreign_key: { on_delete: :nullify }
      t.timestamps
    end
  end
end
