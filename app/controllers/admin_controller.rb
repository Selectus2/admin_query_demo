class AdminController < ApplicationController
  include AdminHelper

  def dashboard
    @stats = {
      total_users: User.count,
      active_users: User.active.count,
      total_orders: Order.count,
      pending_orders: Order.pending.count,
      total_revenue: Order.completed.sum(:total).to_f,
      low_stock_products: Product.low_stock.count
    }

    @recent_orders = Order.includes(:user).order(created_at: :desc).limit(5)
    @recent_users = User.order(created_at: :desc).limit(5)
  end

  def query
    @query_text = params[:query]

    if @query_text.present?
      @result = process_natural_language_query(@query_text)
      Rails.logger.info "Admin Query: #{@query_text} | Success: #{@result[:success]}"
    end

    respond_to do |format|
      format.html
      format.json { render json: @result }
    end
  end
end
