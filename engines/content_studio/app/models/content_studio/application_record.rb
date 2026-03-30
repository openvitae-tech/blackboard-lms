# frozen_string_literal: true

module ContentStudio
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
