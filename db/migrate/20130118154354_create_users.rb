class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|

    	t.string   :name
    	t.string   :email
    	t.string   :avatar_file_name
    	t.string   :avatar_content_type
    	t.integer  :avatar_file_size
    	t.datetime :avatar_updated_at
    	t.string   :password_digest
    	t.boolean  :is_admin, :default => false

      t.timestamps
    end
    
    add_index "users", ["email"], :name => "index_users_on_email", :unique => true

  end
end
