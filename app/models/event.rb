class Event < ActiveRecord::Base
	has_many :events_user
	has_many :user, :through => :events_user
	has_many :taggings
	has_many :tags, :through => :taggings 

	Paperclip.options[:command_path] = 'C:\Program Files\ImageMagick-6.9.2-Q16'
	
	belongs_to :user

	Time.zone = "Mexico City"

	validates :datetime, date: {after_or_equal_to: Proc.new {Time.zone.now}}
	validates :name, presence: true
	validates :location, presence: true
	validates :all_tags, presence: true

	has_attached_file :image, styles: { medium: "300x300>" }
	validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

	def all_tags=(names)
  		self.tags = names.split(",").map do |name|
      		Tag.find_or_create_by!(name: name.strip)
  		end
	end

	def all_tags
  		self.tags.map(&:name).join(", ")
	end

	def self.tagged_with(name)
  		Tag.find_by_name!(name).events
	end
end
