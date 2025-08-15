# frozen_string_literal: true
# scripts/seed.rb
require_relative '../agenda'

agenda = Agenda.new

samples = [
  { name: 'Ana Silva',    phone: '27 99999-0000', email: 'ana@exemplo.com',  birthday: '1995-03-10' },
  { name: 'Bruno Costa',  phone: '(27) 98888-1111', email: 'bruno@exemplo.com', birthday: '1992-12-05' },
  { name: 'Carla Souza',  phone: '27977772222', email: 'carla@exemplo.com', birthday: nil },
  { name: 'Diego Santos', phone: '27 90000 3333', email: 'diego@exemplo.com', birthday: '1989-06-21' }
]

added = 0
samples.each do |s|
  begin
    agenda.add(**s)
    added += 1
  rescue => e
    warn "Falhou ao adicionar #{s[:name]}: #{e.message}"
  end
end

puts "Seeds inseridos: #{added}"
