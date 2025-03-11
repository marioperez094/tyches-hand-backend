require 'rails_helper'

RSpec.describe CardEffectCalculator do
  describe '#calculate_value' do
    subject { described_class.new(effect, card_name, card_rank) }

    context 'when effect is Exhumed' do
      let(:effect)     { 'Exhumed' }
      let(:card_name)  { "Exhumed Jack of Hearts" }
      let(:card_rank)  { 11 }
      
      it 'calculates the correct value' do
        # For Exhumed
        expected_value = (1 + 0.5 * card_rank / 15.0).round
        expect(subject.calculate_value).to eq(expected_value)
      end
    end
  end

  describe '#description' do
    subject { described_class.new(effect, card_name, card_rank) }
    
    context 'when effect is Exhumed' do
      let(:effect)     { 'Exhumed' }
      let(:card_name)  { "Exhumed Jack of Hearts" }
      let(:card_rank)  { 11 }
      
      it 'returns the correct description' do
        expected_description = "Cards ripped from a corpse's stiff grip."
        expect(subject.description).to eq(expected_description)
      end

      it 'returns the correct effect_description' do
        expected_description = 'Increases blood pot payout on a win.'
        expect(subject.effect_description).to eq(expected_description)
      end
    end
  end

  describe '#effect_type' do
    subject { described_class.new(effect, card_name, card_rank) }

    context 'when effect is Exhumed' do
      let(:effect)     { 'Exhumed' }
      let(:card_name)  { "Exhumed Jack of Hearts" }
      let(:card_rank)  { 11 }
      
      it 'returns the correct effect type' do
        expect(subject.effect_type).to eq('Pot')
      end
    end
  end
end
