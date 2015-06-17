require 'pyro'
require 'time'
require 'httparty'

OAUTH_TOKEN = "XXXXXXXXXX"
FACEBOOK_ID = "XXXXXXXXXX"
SLACK_URL = "https://hooks.slack.com"

class NilClass
  def try *args
    nil
  end
end

class Object
  def try met, arg
    self.send(met, arg)
  end
end

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

  def get_nearby_users
    users = super
    results = users["results"]

    sleep(7)
    puts "#{results.count} users nearby"
    results
  end

  def generate_matches(matches, number_of_swipes = 3)
    puts "Swiping right on #{number_of_swipes} users of #{matches.count} nearby"

    matches.sample(number_of_swipes).each do |user|
      self.like(user["_id"])
      sleep(2)
    end
  end

  def get_matches_with_messages(messages_count = 1)
    updates = self.fetch_all_updates
    sleep(2)
    matches = updates["matches"].select { |match|  match["messages"].length == messages_count }
    #Slack.post_as_tinderfish("#{matches.count} matches have sent messages to you!")
    puts "#{matches.count} matches have sent messages to you!"
    matches
  end

  def new_messages_from?(victim, since)
    updates = self.fetch_updates(DateTime.parse(since))
    matches = updates.parsed_response["matches"]

    if matches.any?
      message_updates_from_victim = matches.select { |match| match["messages"].last.try(:[], "from") == victim.id }
      message_updates_from_victim = message_updates_from_victim.select { |match| match["messages"].last["message"] != victim.last_message }

      if message_updates_from_victim.any?
        newest_message = message_updates_from_victim.first["messages"].last
        victim.last_message = newest_message["message"].sanitise_for_name
        victim.last_message_sent_at = newest_message["sent_date"]
        true
      else
        false
      end
    end
  end

  def run(victim_one, victim_two)
    # Introduce our victims on Slack
    Slack.post_as_victim(victim_one, "*Victim One*\n*Bio:* #{victim_one.bio}\n*First Message:* #{victim_one.last_message}")
    Slack.post_as_victim(victim_two, "*Victim Two*\n*Bio:* #{victim_two.bio}\n*First Message:* #{victim_two.last_message}")

    # Send Initial message to kick start convo
    Slack.post_as_tinderfish("Let's get started... I'm sending this from *#{victim_one.name}* to *#{victim_two.name}*\n_#{victim_one.last_message}_")
    self.send_message(victim_two.match_id, victim_one.last_message)

    # Main loop
    loop do
      until self.new_messages_from?(victim_two, victim_one.last_message_sent_at) do
        seconds = rand(60...120)
        puts "Sleeping for #{seconds} seconds, waiting for #{victim_two.name}..."
        sleep(seconds)
      end

      puts "------------------ New Message! --------------------"
      puts "From:     #{victim_two.name}"
      puts "Message:  #{victim_two.last_message}"
      puts "Sending this to #{victim_one.name}..."
      puts "----------------------------------------------------"

      Slack.post_as_victim(victim_two, victim_two.last_message)
      self.send_message(victim_one.match_id, victim_two.last_message)


      until self.new_messages_from?(victim_one, victim_two.last_message_sent_at) do
        seconds = rand(60...120)
        puts "Sleeping for #{seconds} seconds, waiting for #{victim_one.name}..."
        sleep(seconds)
      end

      puts "------------------ New Message! --------------------"
      puts "From:     #{victim_one.name}"
      puts "Message:  #{victim_one.last_message}"
      puts "Sending this to #{victim_two.name}..."
      puts "----------------------------------------------------"

      Slack.post_as_victim(victim_one, victim_one.last_message)
      self.send_message(victim_two.match_id, victim_one.last_message)
    end
  end
end

class Victim
  attr_accessor :id, :name, :bio, :messages, :last_message, :last_message_sent_at, :photo, :match_id

  def initialize(match)
    @id = match["person"]["_id"]
    @name = match["person"]["name"]
    @bio = match["person"]["bio"]
    @messages = match["messages"].sort_by { |obj| obj["sent_date"] }
    @last_message = @messages.last["message"].sanitise_for_name
    @last_message_sent_at = @messages.last["sent_date"]
    @photo = match["person"]["photos"].first["processedFiles"].first["url"]
    @match_id = match["_id"]
  end
end

class Slack
  def self.post_as_victim victim, message
    payload = {
      username: victim.name,
      text: message,
      icon_url: victim.photo
    }

    HTTParty.post(SLACK_URL, { body: { payload: payload.to_json }})
  end

  def self.post_as_tinderfish message
    payload = {
      username: "Tinderfish",
      text: message,
      icon_url: "http://www.spencerlloyddixon.co.uk/wp-content/uploads/2015/03/tinderfish-300x300.jpg"
    }

    HTTParty.post(SLACK_URL, { body: { payload: payload.to_json }})
  end

  def log_to_all(message, victim=nil)
    if victim.nil?
      self.post_as_tinderfish(message)
    else
      self.post_as_victim(victim, message)
    end

    puts message
  end
end

# Sign in
# tinderfish = Tinderfish.new
# tinderfish.sign_in(FACEBOOK_ID, OAUTH_TOKEN)

# Select first two victims
# victim_one = Victim.new(matches[0])
# victim_two = Victim.new(matches[1])

# Manually match our victims
# matches = tinderfish.get_matches_with_messages(1)
# v1 = matches.select { |match| match["person"]["_id"] == "XXXX" }
# victim_one = Victim.new(v1.first)
#
# matches = tinderfish.get_matches_with_messages(3)
# v2 = matches.select { |match| match["person"]["_id"] == "XXXX" }
# victim_two = Victim.new(v2.first)

# Run the program
#tinderfish.run(victim_one, victim_two)
