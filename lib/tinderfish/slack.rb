module Tinderfish
  class Slack
    SLACK_URL = "https://hooks.slack.com"

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
  end
end
