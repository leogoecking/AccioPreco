module ApplicationHelper
  include Pagy::Frontend

  def format_currency(amount)
    return "" if amount.blank?

    number_to_currency(amount, unit: "R$", separator: ",", delimiter: ".")
  end
end
