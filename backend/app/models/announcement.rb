# frozen_string_literal: true

# announcements table
class Announcement < ActiveRecord::Base
  validates :title,      presence: true
  validates :message,    presence: true

  # Return all announcements.
  #
  # @return all announcements
  def self.find_all
    Announcement.order(created_at: :desc)
  end

  # Return a specific announcement.
  #
  # @param id [Int] the id of the announcement
  # @return the announcements
  def self.find_id(id)
    Announcement.find_by(id: id)
  end

  # Create an announcement
  #
  # @param announcement [Hash] the announcement
  # @option announcement[:title] [String] the title
  # @option announcement[:message] [String] the message
  # @option announcement[:active] [String] active - interpreted as Boolen
  # return the announcement
  def self.create_from(announcement)
    # Read the parameters
    title = Input.text(announcement[:title])
    message = Input.text(announcement[:message])
    active = Input.boolean(announcement[:active])

    announcement_new = Announcement.new(
      title: title,
      message: message,
      active: active
    )

    valid = announcement_new.valid?
    return false, announcement_new.errors if !valid

    # Save the announcement if it is valid
    announcement_new.save

    return announcement_new, false
  end

  # Update an announcement
  #
  # @param announcement [Hash] the announcement
  # @option announcement[:title] [String] the title
  # @option announcement[:message] [String] the message
  # @option announcement[:active] [String] active - interpreted as Boolen
  # return the announcement
  def update(announcement)
    # Read the parameters
    input_title = Input.text(announcement[:title])
    input_message = Input.text(announcement[:message])
    input_active = Input.boolean(announcement[:active])

    self.title = input_title
    self.message = input_message
    self.active = input_active

    valid = self.valid?
    return false, self.errors if !valid

    # Save the announcement if it is valid
    self.save

    return self, false
  end
end
