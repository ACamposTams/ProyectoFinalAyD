class CreateSocials < ActiveRecord::Migration
  def change
    create_table :socials do |t|

    	t.string   :name
	    t.text     :description
	    t.integer  :user_id
	    t.datetime :datetime
	    t.string   :location
	    t.string   :image_file_name
	    t.string   :image_content_type
	    t.integer  :image_file_size
	    t.datetime :image_updated_at
	    t.string   :tags, default: "{}"
	    t.string   :category
      t.timestamps null: false
    end
  end
end
