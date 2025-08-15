# frozen_string_literal: true
# contact.rb
require 'date'

class Contact
  class ValidationError < StandardError; end

  EMAIL_REGEX = /\A[^@\s]+@[^@\s]+\.[^@\s]+\z/
  PHONE_REGEX = /\A\d{8,15}\z/ # 8 a 15 dígitos

  attr_accessor :id, :name, :phone, :email, :birthday

  def initialize(id:, name:, phone:, email:, birthday: nil)
    @id = id
    @name = name.to_s.strip
    @phone = normalize_phone(phone)
    @email = email.to_s.strip
    @birthday = parse_date(birthday)
    validate!
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
      id: hash['id'] || hash[:id],
      name: hash['name'] || hash[:name],
      phone: hash['phone'] || hash[:phone],
      email: hash['email'] || hash[:email],
      birthday: hash['birthday'] || hash[:birthday]
    )
  end

  def self.valid_email?(value)
    !!(value.to_s.strip =~ EMAIL_REGEX)
  end

  def self.valid_phone?(value)
    !!(value.to_s.gsub(/\D/, '') =~ PHONE_REGEX)
  end

  private

  def validate!
    raise ValidationError, 'Nome obrigatório' if name.empty?
    raise ValidationError, 'Telefone inválido (use 8 a 15 dígitos)' unless self.class.valid_phone?(phone)
    raise ValidationError, 'E-mail inválido' unless self.class.valid_email?(email)
  end

  def normalize_phone(value)
    value.to_s.gsub(/\D/, '')
  end

  def parse_date(value)
    return nil if value.nil? || value.to_s.strip.empty?
    return value if value.is_a?(Date)
    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end
