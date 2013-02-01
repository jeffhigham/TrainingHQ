class CreateJournalEntries < ActiveRecord::Migration
  def change
    create_table :journal_entries do |t|
      t.integer :user_id
      t.string :category
      t.string :subject
      t.text :body

      t.timestamps
    end
  end
end
