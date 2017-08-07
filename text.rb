require 'twilio-ruby'

twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']

client = Twilio::REST::Client.new twilio_account_sid, twilio_auth_token

client.messages.create(
  to: "(408)242-8413",
  from: '+12152341848',
  body: "Hi François! :)",
)
