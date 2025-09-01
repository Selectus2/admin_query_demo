# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Clear existing data
User.destroy_all
Order.destroy_all
Product.destroy_all

# Create sample users
puts "Creating users..."
20.times do
  User.create!(
    name: Faker::Name.name,
    email: Faker::Internet.unique.email,
    status: [ 'active', 'inactive', 'pending' ].sample,
    created_at: rand(90.days.ago..Time.current)
  )
end

# Create sample products
puts "Creating products..."
categories = [ 'Electronics', 'Books', 'Clothing', 'Home', 'Sports' ]
30.times do
  Product.create!(
    name: Faker::Commerce.product_name,
    price: rand(10.0..500.0).round(2),
    category: categories.sample,
    stock: rand(0..100)
  )
end

# Create sample orders
puts "Creating orders..."
User.find_each do |user|
  rand(0..5).times do
    Order.create!(
      user: user,
      total: rand(20.0..300.0).round(2),
      status: [ 'pending', 'completed', 'cancelled', 'refunded' ].sample,
      order_date: rand((Date.current - 60.days)..Date.current)
    )
  end
end

puts "Sample data created successfully!"
puts "Users: #{User.count}"
puts "Products: #{Product.count}"
puts "Orders: #{Order.count}"
