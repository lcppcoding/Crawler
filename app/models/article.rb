class Article < ApplicationRecord
  scope :query, ->(str) { where('title ILIKE ?', "%#{str}%") if str.present? }

  enum source: ['Cultura', 'Desenvolvimento Social']
  validates :url, :title, :publish_date, :collect_date, :content, :source, presence: true
  validates :url, uniqueness: { message: 'already persisted' }
end
