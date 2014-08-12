class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string   :title
      t.text     :content
      t.date     :post_date
      t.datetime :updated_at
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :posts
  end
end
