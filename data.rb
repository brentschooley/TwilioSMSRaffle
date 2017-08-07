require 'rest-firebase'
require 'pp'
require 'twilio-ruby'

twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']

f = RestFirebase.new :site => ENV['RAFFLE_FIREBASE_URL'], :secret => ENV['RAFFLE_FIREBASE_SECRET']
entries = f.get('entries')
# pp entries.to_a

client = Twilio::REST::Client.new twilio_account_sid, twilio_auth_token

entries.each do |entry|
  client.messages.create(
    to: "+#{entry[0]}",
    from: '+12152341848',
    body: "Hi #{entry[1].partition(" ").first}, this is Brent from Twilio. Before I delete your phone number I wanted to make sure you had a Twilio promo code. Sign up at http://twilio.com/try-twilio and use the promo code PHILLYCC2017 when you upgrade for $25 credit. Thanks again!",
  )
end
