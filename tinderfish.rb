require 'pyro'
require 'time'

OAUTH_TOKEN = "CAAGm0PX4ZCpsBABp4TKZBwhfZCu1wO5ZBaaZAwgAIhGJMNQ4vqYUZC6aZBmID7Ch6aZB8vY8fJ0GQg43AiTOGe0RjcJZAMXoV8WKxlSFRwIoqLlxTxnESCcS7fSvrVqUgcTvbmZCsX3ttVrDZAmNVaLS49lfUzgS9B2fCY09G6O5UcYyfJruFLMfxO5EOaNQZAyNTcSdTCuXWBIZA67kVc5GRqn2P0ALXyCHBZAQIZD"
FACEBOOK_ID = "100009335141764"

class String
  def sanitise_for_name
    self.gsub(/christine/i, "")
  end
end

class Tinderfish < TinderPyro::Client
  def sign_in(facebook_id, facebook_token)
    puts "Signing in to Tinder account..."
    response = super(facebook_id, facebook_token)
    sleep(4)
    puts response["code"] == 500 ? "Error - Token expired" : "Signed in successfully!"
  end

  def generate_matches(number_of_swipes = 3)
    users = tinderfish.get_nearby_users
    results = users["results"]
    puts "Swiping right on #{number_of_swipes} users of #{results.count} users nearby"
    sleep(7)

    results.sample(number_of_swipes).each do |user|
      tinderfish.like(user["_id"])
      sleep(2)
    end
  end

  def get_matches_with_messages(messages_count = 1)
    updates = self.fetch_all_updates
    sleep(2)
    matches = updates["matches"].select { |match|  match["messages"].length == messages_count }
    puts "#{matches.count} matches have sent messages to you!"
    matches
  end

  def new_messages_from?(victim, since)
    updates = self.fetch_updates(DateTime.parse(since))
    matches = updates.parsed_response["matches"]

    if matches.any?
      message_updates_from_victim = matches.select { |match| match["messages"].first["from"] == victim.id }
      message_updates_from_victim = message_updates_from_victim.select { |match| match["messages"].first["message"] != victim.last_message }

      if message_updates_from_victim.any?
        newest_message = message_updates_from_victim.first["messages"].first
        victim.last_message = newest_message["message"].sanitise_for_name
        victim.last_message_sent_at = newest_message["sent_date"]
        true
      else
        false
      end
    end
  end
end

class Victim
  attr_accessor :id, :name, :bio, :messages, :last_message, :last_message_sent_at

  def initialize(match)
    @id = match["person"]["_id"]
    @name = match["person"]["name"]
    @bio = match["person"]["bio"]
    @messages = match["messages"].sort_by { |obj| obj["sent_date"] }
    @last_message = @messages[0]["message"].sanitise_for_name
    @last_message_sent_at = @messages[0]["sent_date"]
  end
end

tinderfish = Tinderfish.new
tinderfish.sign_in(FACEBOOK_ID, OAUTH_TOKEN)
matches = tinderfish.get_matches_with_messages(1)

victim_one = Victim.new(matches[0])
  puts "------------------- Victim One ---------------------"
  puts "ID:       #{victim_one.id}"
  puts "Name:     #{victim_one.name}"
  puts "Bio:      #{victim_one.bio}"
  puts "Message:  #{victim_one.last_message}"
  puts "----------------------------------------------------"
victim_two = Victim.new(matches[1])
  puts "------------------- Victim Two ---------------------"
  puts "ID:       #{victim_two.id}"
  puts "Name:     #{victim_two.name}"
  puts "Bio:      #{victim_two.bio}"
  puts "Message:  #{victim_two.last_message}"
  puts "----------------------------------------------------"

  puts "Sending initial message from #{victim_one.name} to #{victim_two.name}..."

tinderfish.send_message(victim_two.id, victim_one.last_message)

loop do
  puts "Waiting for new message from #{victim_two.name}..."
  until tinderfish.new_messages_from?(victim_two, victim_two.last_message_sent_at) do
    seconds = rand(120...300)
    sleep(seconds)
    puts "-- Sleeping..."
  end

  puts "------------------ New Message! --------------------"
  puts "From:     #{victim_two.name}"
  puts "Message:  #{victim_two.last_message}"
  puts "Sending this to #{victim_one.name}..."
  puts "----------------------------------------------------"

  tinderfish.send_message(victim_one.id, victim_two.last_message)

  until tinderfish.new_messages_from?(victim_one, victim_two.last_message_sent_at) do
    seconds = rand(120...300)
    sleep(seconds)
    puts "-- Sleeping..."
  end

  puts "------------------ New Message! --------------------"
  puts "From:     #{victim_one.name}"
  puts "Message:  #{victim_one.last_message}"
  puts "Sending this to #{victim_two.name}..."
  puts "----------------------------------------------------"

  tinderfish.send_message(victim_two.id, victim_one.last_message)
end
