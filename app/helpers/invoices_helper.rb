module InvoicesHelper
  def formatted_bill_date(bill_date)
    bill_date.strftime("%B %d, %Y")
  end

  def due_date(bill_date)
    (bill_date + 1.month).strftime("%B %d, %Y")
  end

  def invoice_id(id)
    id.to_s.rjust(6, '0')
  end
end
