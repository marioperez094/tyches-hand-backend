require 'rails_helper'

RSpec.describe CardEffectCalculator do
  describe '#calculate_value' do

    context 'when effect is Exhumed' do
      let(:effect)     { 'Exhumed' }
      let(:card_name)  { "Exhumed Jack of Hearts" }
      let(:card_rank)  { 10 }
      
      it 'calculates the correct value' do
        # For Exhumed
        expected_value = (25 * card_rank / 15.0).round
        expect(CardEffectCalculator.effect_values(effect, card_rank)).to eq('blood_pot' => { 'value' => expected_value, 'apply_on_phase' => 'on_win'})
      end
    end
  end

  describe '#description' do    
    context 'when effect is Exhumed' do
      let(:effect)     { 'Exhumed' }
      let(:card_name)  { "Exhumed Jack of Hearts" }
      let(:card_rank)  { 10 }
      
      it 'returns the correct description' do
        expected_description = "Cards ripped from a corpse's stiff grip."
        expect(CardEffectCalculator.description(effect)).to eq(expected_description)
      end

      it 'returns the correct effect_description' do
        expected_description = 'Increases blood pot payout on a win.'
        effect_type = CardEffectCalculator.effect_type(effect)
        expect(EffectTypes::EFFECT_ACTIONS[effect_type][:description]).to eq(expected_description)
      end
    end
  end

  describe '#effect_type' do
    context 'when effect is Exhumed' do
      let(:effect)     { 'Exhumed' }
      let(:card_name)  { "Exhumed Jack of Hearts" }
      let(:card_rank)  { 11 }
      
      it 'returns the correct effect type' do
        expect(CardEffectCalculator.effect_type(effect)).to eq('increase_pot_on_win')
      end
    end
  end
end
