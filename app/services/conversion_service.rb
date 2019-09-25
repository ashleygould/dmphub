# frozen_string_literal: true

# Provides conversion methods for JSON <--> Model
class ConversionService
  class << self
    # Converts a boolean field to [yes, no, unknown]
    def boolean_to_yes_no_unknown(value)
      return 'yes' if value == true

      return 'no' if value == false

      'unknown'
    end

    # Converts a [yes, no, unknown] field to boolean (or nil)
    def yes_no_unknown_to_boolean(value)
      return true if value == 'yes'

      return nil if value.blank? || value == 'unknown'

      false
    end
  end
end
