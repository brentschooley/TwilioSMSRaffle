require 'rest-firebase'
require 'pp'

f = RestFirebase.new :site => ENV['RAFFLE_FIREBASE_URL'], :secret => ENV['RAFFLE_FIREBASE_SECRET']
entries = f.get('entries')
pp entries.to_a.count
