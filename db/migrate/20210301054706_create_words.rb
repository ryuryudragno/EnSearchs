class CreateWords < ActiveRecord::Migration[5.2]
  def change
    create_table :words do |t|
      t.string :word
      t.string :goo
      t.string :enhack
      t.boolean :important
      t.timestamps null: false
    end
  end
end
