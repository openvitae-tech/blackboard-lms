# frozen_string_literal: true

class InvoicePolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @invoice = record
  end

  def index?
    user.is_admin? || user.is_owner?
  end
end
