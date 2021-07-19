module ApplicationHelper
  def parse_amount(amount)
    return ActionController::Base.helpers.number_to_currency(amount)
  end
end
