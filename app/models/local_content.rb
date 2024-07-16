class LocalContent < ApplicationRecord
  SUPPORTED_LANGUAGES = {
    hindi: "Hindi",
    tamil: "Tamil",
    marathi: "Marathi",
    bengali: "Bengali",
    kannada: "Kannada",
    malayalam: "Malayalam"
  }

  belongs_to :lesson
end
