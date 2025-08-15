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

  # order: :name (default) | :birthday
  def all(order: :name)
    case order
    when :birthday
      @contacts.sort_by { |c| [c.birthday ? c.birthday.month : 13, c.birthday ? c.birthday.day : 32, c.name.downcase] }
    else
      @contacts.sort_by { |c| c.name.downcase }
    end
  end

  def search(query)
    q = query.to_s.downcase.strip
    return [] if q.empty?
    @contacts.select do |c|
      [c.name, c.phone, c.email].compact.any? { |f| f.downcase.include?(q) }
    end
  end

  def add(name:, phone:, email:, birthday: nil)
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
    updated_hash = contact.to_h.merge(
      name:  fields.fetch(:name, contact.name),
      phone: fields.fetch(:phone, contact.phone),
      email: fields.fetch(:email, contact.email),
      birthday: fields.key?(:birthday) ? fields[:birthday] : contact.birthday
    )
    # revalida ao reconstruir
    updated = Contact.from_h(updated_hash)
    # substitui
    idx = @contacts.index(contact)
    @contacts[idx] = updated
    persist!
    updated
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

  # Importar CSV com colunas: id (opcional), name, phone, email, birthday (YYYY-MM-DD)
  # Retorna um relatório {imported:, skipped:, errors:[]}
  def import_csv(path, generate_ids: true, skip_invalid: true)
    raise "Arquivo não encontrado: #{path}" unless File.exist?(path)
    report = { imported: 0, skipped: 0, errors: [] }

    CSV.foreach(path, headers: true) do |row|
      begin
        attrs = row.to_h.transform_keys(&:downcase)
        id = attrs['id']
        id = SecureRandom.uuid if (id.nil? || id.strip.empty?) && generate_ids

        contact = Contact.new(
          id: id,
          name: attrs['name'],
          phone: attrs['phone'],
          email: attrs['email'],
          birthday: attrs['birthday']
        )
        @contacts << contact
        report[:imported] += 1
      rescue => e
        if skip_invalid
          report[:skipped] += 1
          report[:errors] << { row: row.to_h, error: e.message }
        else
          raise
        end
      end
    end

    persist!
    report
  end

  private

  def find_by_id!(id)
    @contacts.find { |c| c.id == id } || (raise "Contato não encontrado: #{id}")
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
