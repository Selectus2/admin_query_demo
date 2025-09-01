class Order < ApplicationRecord
  belongs_to :user

  validates :total, presence: true, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: %w[pending completed cancelled refunded] }

  scope :completed, -> { where(status: "completed") }
  scope :pending, -> { where(status: "pending") }
  scope :recent, -> { where("order_date > ?", 30.days.ago) }
  scope :this_month, -> { where(order_date: Date.current.beginning_of_month..Date.current.end_of_month) }
end
