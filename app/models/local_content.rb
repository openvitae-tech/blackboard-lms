class LocalContent < ApplicationRecord
  DEFAULT_LANGUAGE = "english"

  SUPPORTED_LANGUAGES = {
    hindi: "Hindi",
    tamil: "Tamil",
    marathi: "Marathi",
    bengali: "Bengali",
    kannada: "Kannada",
    malayalam: "Malayalam",
    english: "English",
  }

  belongs_to :lesson
end
