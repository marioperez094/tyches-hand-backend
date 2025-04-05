class EffectValuesFormatValidator < ActiveModel::EachValidator
  VALID_PHASES = %w[on_equip round_start hand_start on_win on_loss on_push].freeze

  def validate_each(record, attribute, value)
    return if value == {}

    unless value.is_a?(Hash)
      record.errors.add(attribute, "must be a hash")
      return
    end

    value.each do |effect_key, data|
      unless data.is_a?(Hash)
        record.errors.add(attribute, "#{effect_key} must be a hash with 'value' and 'apply_on_phase'")
        next
      end

      unless data.key?("value") && data.key?("apply_on_phase")
        record.errors.add(attribute, "#{effect_key} must contain 'value' and 'apply_on_phase'")
      end

      if data["value"].nil? || !data["value"].is_a?(Numeric)
        record.errors.add(attribute, "#{effect_key}.value must be a number")
      end

      unless VALID_PHASES.include?(data["apply_on_phase"])
        record.errors.add(attribute, "#{effect_key}.apply_on_phase must be a valid phase")
      end
    end
  end
end
