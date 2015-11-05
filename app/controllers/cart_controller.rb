class CartController < ApplicationController


  def index
    ids = @current_cart.cart_items.keys
    @amounts = @current_cart.cart_items.values
    @users = User.includes(:loan_requests).where(loan_requests: {id: ids})
  end

  def create
    @current_cart.add_item(params[:loan_request], params[:amount])
    session[:cart] = @current_cart.cart_items
    flash[:notice] = "#{LoanRequest.find(params[:loan_request]).title} Added to Basket"
    redirect_to(:back)
  end

  def delete
    @current_cart.delete_loan_request(params[:format])
    redirect_to cart_path
  end

  def update
    if params[:quantity] == "increase"
      @current_cart.increase_loan_request_amount(params[:loan_request_id])
      redirect_to cart_path
    elsif params[:quantity] == "decrease"
      @current_cart.decrease_loan_request_amount(params[:loan_request_id])
      redirect_to cart_path
    end
  end
end
