# frozen_string_literal: true

ResponseObject = Data.define(:status, :data) do
  def ok?
    status == :ok
  end

  def self.ok(data = nil)
    new(:ok, data)
  end

  def self.error(data = nil)
    new(:error, data)
  end
end
