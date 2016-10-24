require 'sinatra'
require 'twilio-ruby'
require 'sinatra/run-later'
require 'rest-firebase'
require 'pp'

firebase_url = ENV['RAFFLE_FIREBASE_URL']
firebase_secret = ENV['RAFFLE_FIREBASE_SECRET']
twilio_account_sid = ENV['TWILIO_ACCOUNT_SID']
twilio_auth_token = ENV['TWILIO_AUTH_TOKEN']
event_programming_language = ENV['RAFFLE_PROGRAMMING_LANGUAGE']
notification_tutorial_link = ENV['RAFFLE_NOTIFICATION_TUTORIAL_LINK']
twitter_url = ENV['TWITTER_URL']
sms_code_gif = ENV['SMS_CODE_GIF']

post '/incoming_message' do
  content_type 'text/xml'

  from = params['From']
  from.slice!(0)
  body = params['Body']

  if body.split.size == 1
    if body.strip.downcase == "name"
      response = Twilio::TwiML::Response.new do |r|
        r.Message "I think you took the sign a little too literally. Please send your first and last name to this number. Thanks :)"
      end

      return response.to_xml
    end
    response = Twilio::TwiML::Response.new do |r|
      r.Message "You only sent me a first name. I need a first and last name. Please try again!"
    end

    return response.to_xml
  end

  f = RestFirebase.new :site => firebase_url, :secret => firebase_secret

  entry = f.get("entries/#{from}")

  if !entry.nil?
    p "Entry: #{entry}"
    p body
    if entry.strip.downcase == body.strip.downcase
      response = Twilio::TwiML::Response.new do |r|
        r.Message "Very sneaky trying to enter more than once. Nice try! Only one entry per person."
      end
      return response.to_xml
    end
    f.put("entries/#{from}", body)
    response = Twilio::TwiML::Response.new do |r|
      r.Message "You already entered the raffle! I updated your name to what you sent in this message. Thanks for entering!"
    end
    return response.to_xml
  end

  f.put("entries/#{from}", body)

  run_later do
    client = Twilio::REST::Client.new twilio_account_sid, twilio_auth_token
    client.messages.create(
      to: from,
      from: params['To'],
      body: "Open this GIF to see how to respond to and send SMS using Twilio with #{event_programming_language}. Get this code and learn more at #{notification_tutorial_link}. If you need help, find me on Twitter (#{TWITTER_URL}).",
      media_url: ENV['SMS_CODE_GIF']
    )
  end

  Twilio::TwiML::Response.new do |r|
    r.Message do |m|
      m.Body "Thanks for entering the raffle #{body}! This raffle is powered by Twilio. In a moment I'll send you a GIF that shows you how it works."
    end
  end.to_xml
end

get '/pick_winner' do
  f = RestFirebase.new :site => firebase_url, :secret => firebase_secret
  entries = f.get('entries')
  winner = entries.to_a.sample
  code = "<%= winner[1] %>"
  f.delete("entries/#{winner[0].strip}")
  erb code, :locals => {:winner => winner}
end
