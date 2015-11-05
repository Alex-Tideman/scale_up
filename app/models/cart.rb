class Cart
  attr_accessor :cart_items

  def initialize(cart_items)
    @cart_items = cart_items || Hash.new
  end

  def add_item(loan_request_id, amount)
    @cart_items[loan_request_id] ||= 0
    @cart_items[loan_request_id] += amount.to_i
  end

  def cart_items_and_amount
    ids = cart_items.keys
    amounts = cart_items.values
    LoanRequest.find(ids)
    # loan_requests.zip(amounts).to_h
  end

  def delete_loan_request(loan_request_id)
    @cart_items.delete(loan_request_id)
  end

  def increase_loan_request_amount(loan_request_id)
    @cart_items[loan_request_id] += 25
  end

  def decrease_loan_request_amount(loan_request_id)
    if @cart_items[loan_request_id] > 25
      @cart_items[loan_request_id] -= 25
    else
      @cart_items.delete(loan_request_id)
    end
  end
end
