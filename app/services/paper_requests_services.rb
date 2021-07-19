class PaperRequestsServices
  
  def initialize(user,rut,address,quantity)
    @user = user
    @rut = rut
    @address = address
    @quantity = quantity
    @base_amount = 700
    @total_amount = get_total_amount

  end

  def create_paper_request_order
    @request_order = @user.paper_requests.create({
      rut: @rut,
      address: @address,
      amount: @total_amount,
      status: 0
    })
    discount_order

    return @request_order
  end

  private

  def get_total_amount
    return @quantity.to_i * @base_amount
  end

  def discount_order
    order = @user.orders.pending.last
    order.update(amount: order.amount - @total_amount)
  end
end