require 'tinderfish/utils'

module Tinderfish
  class Victim
    attr_accessor :id, :name, :bio, :messages, :last_message, :last_message_sent_at, :photo, :match_id
    attr_accessor :person

    def initialize(match)
      self.match_id = match["_id"]

      self.person = match["person"]
      self.id = person["_id"]
      self.name = person["name"]
      self.bio = person["bio"]
      self.messages = match["messages"].sort_by { |obj| obj["sent_date"] }
      self.last_message = messages.last["message"].sanitise_for_name
      self.last_message_sent_at = messages.last["sent_date"]
      self.photo = person["photos"].first["processedFiles"].first["url"]
    end
  end
end
