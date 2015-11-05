class CategoriesController < ApplicationController
  def index
    @categories = Category.page(params[:page]).order('title DESC')
  end

  def show
    @category = Category.find(params[:id])
    @loan_requests = @category.loan_requests.page(params[:page]).order('created_at DESC')
    # @loan_requests = LoanRequest.joins(:categories).where(categories: {id: @category.id}).page(params[:page]).order('created_at DESC')
  end
end
