require 'pyro'
require 'tinderfish/slack'
require 'tinderfish/victim'

module Tinderfish
  class Fisher < TinderPyro::Client
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
        like(user["_id"])
        sleep(2)
      end
    end

    def get_matches_with_messages(messages_count = 1)
      updates = self.fetch_all_updates
      sleep(2)
      matches = updates["matches"].select { |match|  match["messages"].length == messages_count }
      #Tinderfish::Slack.post_as_tinderfish("#{matches.count} matches have sent messages to you!")
      puts "#{matches.count} matches have sent messages to you!"
      matches
    end

    WITH_MESSAGES = -> match { match['messages'].any? }
    LAST_MESSAGES = -> match { match['messages'].last }
    FROM_VICTIM = -> victim, message { message['from'] == victim.id }
    DIFFERENT_FROM = -> other, message { message['from'] != other }
    def new_messages_from?(victim, since)
      updates = self.fetch_updates(DateTime.parse(since))

      matches = updates.parsed_response["matches"]
      return false if matches.empty?

      new_message_from_victim = matches
        .select(&WITH_MESSAGES)
        .map(&LAST_MESSAGES)
        .select(&FROM_VICTIM.curry[victim])
        .detect(&DIFFERENT_FROM.curry[victim.last_message])

      return false if new_message_from_victim.nil?

      victim.last_message = new_message_from_victim['message'].sanitise_for_name
      victim.last_message_sent_at = new_message_from_victim['sent_date']
      true
    end

    def run(victim_one, victim_two)
      # Introduce our victims on Slack
      Tinderfish::Slack.post_as_victim(victim_one, "*Victim One*\n*Bio:* #{victim_one.bio}\n*First Message:* #{victim_one.last_message}")
      Tinderfish::Slack.post_as_victim(victim_two, "*Victim Two*\n*Bio:* #{victim_two.bio}\n*First Message:* #{victim_two.last_message}")

      # Send Initial message to kick start convo
      Tinderfish::Slack.post_as_tinderfish("Let's get started... I'm sending this from *#{victim_one.name}* to *#{victim_two.name}*\n_#{victim_one.last_message}_")
      self.send_message(victim_two.match_id, victim_one.last_message)

      # Main loop
      loop do
        wait_from(victim_two, victim_one.last_message_sent_at)
        relay_message(from: victim_two, msg: victim_two.last_message, to: victim_one)

        wait_from(victim_one, victim_two.last_message_sent_at)
        relay_message(from: victim_one, msg: victim_one.last_message, to: victim_two)
      end
    end

    private

    def wait_from victim, last_message_sent_at
      until new_messages_from?(victim, last_message_sent_at) do
        seconds = rand(60...120)
        puts "Sleeping for #{seconds} seconds, waiting for #{victim.name}..."
        sleep(seconds)
      end
    end

    def relay_message opts
      puts "------------------ New Message! --------------------"
      puts "From:     #{opts[:from].name}"
      puts "Message:  #{opts[:msg]}"
      puts "Sending this to #{opts[:to].name}..."
      puts "----------------------------------------------------"

      Tinderfish::Slack.post_as_victim(opts[:from], opts[:msg])
      send_message(opts[:to], opts[:msg])
    end
  end
end
