# app/services/recaptcha_v3_verifier.rb
require 'net/http'
require 'uri'
require 'json'

class RecaptchaV3Verifier
  VERIFY_URL = "https://www.google.com/recaptcha/api/siteverify".freeze

  def self.verify(token, minimum_score = 0.5)
    secret_key = ENV['RECAPTCHA_SECRET_KEY']
    return false unless token.present? && secret_key.present?

    uri = URI(VERIFY_URL)
    # Post form: { secret: <SECRET_KEY>, response: <TOKEN> }
    response = Net::HTTP.post_form(uri, {
      "secret" => secret_key,
      "response" => token
    })
    body = JSON.parse(response.body)

    # body["success"] = boolean
    # body["score"] = number from 0.0 to 1.0
    # body["action"] = string (if you used 'action' in your front-end call)
    # body["error-codes"] = array of error strings if any

    if body["success"] == true && body["score"].to_f >= minimum_score
      true
    else
      false
    end
  end
end