# frozen_string_literal: true

class LocalContent < ApplicationRecord
  DEFAULT_LANGUAGE = 'english'

  SUPPORTED_LANGUAGES = {
    hindi: 'Hindi',
    tamil: 'Tamil',
    marathi: 'Marathi',
    bengali: 'Bengali',
    kannada: 'Kannada',
    malayalam: 'Malayalam',
    english: 'English'
  }.freeze

  belongs_to :lesson
end
