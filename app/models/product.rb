class Product < ApplicationRecord
  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :category, presence: true
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }

  scope :low_stock, -> { where("stock < ?", 10) }
  scope :out_of_stock, -> { where(stock: 0) }
  scope :by_category, ->(category) { where(category: category) }
end
