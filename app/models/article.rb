class Article < ApplicationRecord
  enum source: ['Cultura', 'Desenvolvimento Social']
  validates :url, :title, :publish_date, :collect_date, :content, :source, presence: true
  validates :url, uniqueness: true
end
