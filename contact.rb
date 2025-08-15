# frozen_string_literal: true
# contact.rb
require 'date'

class Contact
  attr_accessor :id, :name, :phone, :email, :birthday

  def initialize(id:, name:, phone:, email:, birthday: nil)
    @id = id
    @name = name.strip
    @phone = phone.strip
    @email = email.strip
    @birthday = parse_date(birthday)
  end

  def to_h
    {
      id: id,
      name: name,
      phone: phone,
      email: email,
      birthday: birthday&.strftime('%Y-%m-%d')
    }
  end

  def self.from_h(hash)
    new(
      id: hash['id'],
      name: hash['name'],
      phone: hash['phone'],
      email: hash['email'],
      birthday: hash['birthday']
    )
  end

  private

  def parse_date(value)
    return nil if value.nil? || value.to_s.strip.empty?
    return value if value.is_a?(Date)
    Date.parse(value.to_s) rescue nil
  end
end
