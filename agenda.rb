# frozen_string_literal: true
# agenda.rb
require 'json'
require 'csv'
require 'securerandom'
require 'fileutils'
require_relative 'contact'

class Agenda
  DATA_DIR  = File.join(__dir__, 'data')
  DATA_FILE = File.join(DATA_DIR, 'contatos.json')

  def initialize
    FileUtils.mkdir_p(DATA_DIR)
    @contacts = load_contacts
  end

  def all
    @contacts.sort_by { |c| c.name.downcase }
  end

  def search(query)
    q = query.to_s.downcase.strip
    return [] if q.empty?
    @contacts.select do |c|
      [c.name, c.phone, c.email].compact.any? { |f| f.downcase.include?(q) }
    end
  end

  def add(name:, phone:, email:, birthday: nil)
    validate_presence!(name: name, phone: phone, email: email)
    contact = Contact.new(
      id: SecureRandom.uuid,
      name: name, phone: phone, email: email, birthday: birthday
    )
    @contacts << contact
    persist!
    contact
  end

  def update(id, fields = {})
    contact = find_by_id!(id)
    contact.name = fields[:name] if fields[:name]
    contact.phone = fields[:phone] if fields[:phone]
    contact.email = fields[:email] if fields[:email]
    contact.birthday = fields[:birthday] if fields.key?(:birthday)
    persist!
    contact
  end

  def remove(id)
    before = @contacts.size
    @contacts.reject! { |c| c.id == id }
    persist! if @contacts.size != before
    before != @contacts.size
  end

  def birthdays_in_month(month)
    m = month.to_i
    return [] unless (1..12).include?(m)
    @contacts.select { |c| c.birthday && c.birthday.month == m }
             .sort_by { |c| c.birthday.day }
  end

  def export_csv(path)
    FileUtils.mkdir_p(File.dirname(path))
    CSV.open(path, 'w', write_headers: true, headers: %w[id name phone email birthday]) do |csv|
      @contacts.each { |c| csv << [c.id, c.name, c.phone, c.email, c.birthday&.strftime('%Y-%m-%d')] }
    end
    path
  end

  private

  def find_by_id!(id)
    @contacts.find { |c| c.id == id } || (raise "Contato não encontrado: #{id}")
  end

  def validate_presence!(name:, phone:, email:)
    raise 'Nome obrigatório' if name.to_s.strip.empty?
    raise 'Telefone obrigatório' if phone.to_s.strip.empty?
    raise 'E-mail obrigatório' if email.to_s.strip.empty?
  end

  def load_contacts
    return [] unless File.exist?(DATA_FILE)
    json = JSON.parse(File.read(DATA_FILE))
    Array(json).map { |h| Contact.from_h(h) }
  rescue JSON::ParserError
    []
  end

  def persist!
    File.write(DATA_FILE, JSON.pretty_generate(@contacts.map(&:to_h)))
  end
end
