class CreateArticles < ActiveRecord::Migration[6.1]
  def change
    create_table :articles do |t|
      t.integer :source
      t.string :url
      t.string :title
      t.date :publish_date
      t.date :collect_date
      t.text :content

      t.timestamps
    end
  end
end
