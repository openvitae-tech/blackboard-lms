# frozen_string_literal: true

# Minimal APP_CONFIG stub for the Content Studio dummy app.
# The host app provides the real AppConfigService singleton; this stands in for specs.
APP_CONFIG = Struct.new(:keyword_init) do
  def classroom_kit_enabled? = false
  def microlesson_enabled? = false
end.new
