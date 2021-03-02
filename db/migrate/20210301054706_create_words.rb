class CreateWords < ActiveRecord::Migration[5.2]
  def change
    create_table :words do |t|
      t.integer :user_id
      t.string :word
      t.string :meaning
      t.boolean :important
      t.timestamps null: false
    end
  end
end
