# frozen_string_literal: true
# app.rb
require_relative 'agenda'

def line; puts '-' * 60; end
def prompt(label); print "#{label}: "; gets&.chomp; end
def pause; puts "\nPressione ENTER para continuar..."; STDIN.gets; end

agenda = Agenda.new

loop do
  system('clear') || system('cls')
  puts "AGENDA DE CONTATOS (Ruby)".center(60)
  line
  puts "1) Listar contatos (por nome)"
  puts "2) Buscar contatos"
  puts "3) Adicionar contato"
  puts "4) Editar contato"
  puts "5) Remover contato"
  puts "6) Aniversariantes do mês"
  puts "7) Exportar CSV"
  puts "8) Importar CSV"
  puts "9) Listar por aniversário (mês/dia)"
  puts "0) Sair"
  line
  opc = prompt('Escolha')

  case opc
  when '1'
    puts "\nContatos:"
    agenda.all(order: :name).each_with_index do |c, i|
      bd = c.birthday&.strftime('%d/%m/%Y') || '-'
      puts "#{i+1}. #{c.name} | #{c.phone} | #{c.email} | Nasc.: #{bd} | ID: #{c.id}"
    end
    pause

  when '2'
    q = prompt('Buscar por (nome, telefone ou e-mail)')
    results = agenda.search(q)
    puts "\nResultados (#{results.size}):"
    results.each_with_index do |c, i|
      bd = c.birthday&.strftime('%d/%m/%Y') || '-'
      puts "#{i+1}. #{c.name} | #{c.phone} | #{c.email} | Nasc.: #{bd} | ID: #{c.id}"
    end
    pause

  when '3'
    name = prompt('Nome')
    phone = prompt('Telefone (apenas números)')
    email = prompt('E-mail')
    bday  = prompt('Data de nascimento (YYYY-MM-DD opcional)')
    bday = nil if bday.to_s.strip.empty?
    begin
      c = agenda.add(name: name, phone: phone, email: email, birthday: bday)
      puts "\nContato criado: #{c.name} (ID: #{c.id})"
    rescue => e
      puts "\nErro: #{e.message}"
    end
    pause

  when '4'
    id = prompt('Informe o ID do contato a editar')
    name = prompt('Novo nome (enter p/ manter)')
    phone = prompt('Novo telefone (enter p/ manter)')
    email = prompt('Novo e-mail (enter p/ manter)')
    bday  = prompt('Nova data de nascimento YYYY-MM-DD (enter p/ manter / limpe com -)')
    fields = {}
    fields[:name] = name unless name.to_s.strip.empty?
    fields[:phone] = phone unless phone.to_s.strip.empty?
    fields[:email] = email unless email.to_s.strip.empty?
    if bday == '-'
      fields[:birthday] = nil
    elsif !bday.to_s.strip.empty?
      fields[:birthday] = bday
    end
    begin
      c = agenda.update(id, fields)
      puts "\nAtualizado: #{c.name}"
    rescue => e
      puts "\nErro: #{e.message}"
    end
    pause

  when '5'
    id = prompt('Informe o ID do contato a remover')
    if agenda.remove(id)
      puts "\nContato removido."
    else
      puts "\nNada removido (ID não encontrado)."
    end
    pause

  when '6'
    month = prompt('Mês (1-12)').to_i
    list = agenda.birthdays_in_month(month)
    puts "\nAniversariantes do mês #{month}:"
    list.each_with_index do |c, i|
      puts "#{i+1}. #{c.name} - #{c.birthday.strftime('%d/%m')}"
    end
    pause

  when '7'
    timestamp = Time.now.strftime('%Y%m%d-%H%M%S')
    path = File.join(__dir__, 'exports', "contatos-#{timestamp}.csv")
    agenda.export_csv(path)
    puts "\nExportado para: #{path}"
    pause

  when '8'
    path = prompt('Caminho do CSV para importar')
    begin
      report = agenda.import_csv(path, generate_ids: true, skip_invalid: true)
      puts "\nImportação concluída: #{report[:imported]} importados, #{report[:skipped]} ignorados."
      if report[:errors].any?
        puts "Erros:"
        report[:errors].first(5).each { |er| puts "- #{ er[:error] } (linha: #{er[:row]})" }
        puts "... (total de #{report[:errors].size} erros)" if report[:errors].size > 5
      end
    rescue => e
      puts "\nErro: #{e.message}"
    end
    pause

  when '9'
    puts "\nContatos (ordenados por aniversário):"
    agenda.all(order: :birthday).each_with_index do |c, i|
      bd = c.birthday&.strftime('%d/%m') || '--/--'
      puts "#{i+1}. #{bd} | #{c.name} | #{c.phone} | #{c.email} | ID: #{c.id}"
    end
    pause

  when '0'
    puts "\nAté logo!"
    break

  else
    puts "\nOpção inválida."
    pause
  end
end
