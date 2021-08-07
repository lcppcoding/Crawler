class Article < ApplicationRecord
  enum source: ['Cultura', 'Desenvolvimento Social']
  validates :title, :publish_date, :collect_date, :content, :source, presence: true
  validates :content, uniqueness: true
end
