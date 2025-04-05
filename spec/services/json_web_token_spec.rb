require 'rails_helper'
require 'jwt'

RSpec.describe JsonWebToken, type: :service do
  let(:secret_key) { 'my$ecretK3y' }
  before do
    # Stub the secret key constant to avoid reliance on ENV during tests
    stub_const("JsonWebToken::SECRET_KEY", secret_key)
  end

  describe ".encode" do
    let(:payload) { { user_id: 1 } }
    subject(:token) { JsonWebToken.encode(payload) }

    it "encodes a token that can be decoded to include the original payload" do
      decoded_payload = JWT.decode(token, secret_key).first
      expect(decoded_payload["user_id"]).to eq(1)
    end

    it "includes an expiration claim in the token" do
      decoded_payload = JWT.decode(token, secret_key).first
      expect(decoded_payload).to have_key("exp")
    end

    context "with a custom expiration time" do
      let(:custom_expiration) { 2.hours.from_now }
      subject(:token) { JsonWebToken.encode(payload, custom_expiration) }

      it "sets the custom expiration claim" do
        decoded_payload = JWT.decode(token, secret_key).first
        expect(decoded_payload["exp"]).to eq(custom_expiration.to_i)
      end
    end
  end

  describe ".decode" do
    let(:payload) { { user_id: 1 } }
    let(:token) { JsonWebToken.encode(payload) }

    context "when the token is valid" do
      it "returns a HashWithIndifferentAccess containing the payload" do
        decoded = JsonWebToken.decode(token)
        expect(decoded).to be_a(HashWithIndifferentAccess)
        expect(decoded[:user_id]).to eq(1)
      end
    end

    context "when the token is invalid" do
      it "returns nil" do
        expect(JsonWebToken.decode("invalid.token.here")).to be_nil
      end
    end

    context "when the token is expired" do
      let(:expired_token) { JsonWebToken.encode(payload, 1.hour.ago) }

      it "returns nil when attempting to decode an expired token" do
        expect(JsonWebToken.decode(expired_token)).to be_nil
      end
    end
  end
end
