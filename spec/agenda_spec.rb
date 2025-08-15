# frozen_string_literal: true
require 'fileutils'
require_relative '../agenda'

RSpec.describe Agenda do
  let(:tmp_dir) { File.join(__dir__, 'tmp_data') }
  let(:data_file) { File.join(tmp_dir, 'contatos.json') }

  before do
    stub_const('Agenda::DATA_DIR', tmp_dir)
    stub_const('Agenda::DATA_FILE', data_file)
    FileUtils.mkdir_p(tmp_dir)
    File.write(data_file, '[]')
  end

  after do
    FileUtils.rm_rf(tmp_dir)
  end

  it 'adiciona e lista contatos' do
    a = Agenda.new
    a.add(name: 'Ana', phone: '27999990000', email: 'ana@x.com', birthday: '1995-03-10')
    expect(a.all.size).to eq(1)
  end

  it 'importa CSV e gera relatório' do
    a = Agenda.new
    csv_path = File.join(tmp_dir, 'import.csv')
    File.write(csv_path, "name,phone,email,birthday\nBruno,27988881111,bruno@x.com,1992-12-05\nInvalido,abc,invalido,----\n")
    report = a.import_csv(csv_path, generate_ids: true, skip_invalid: true)
    expect(report[:imported]).to eq(1)
    expect(report[:skipped]).to eq(1)
  end
end
