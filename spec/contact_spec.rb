# frozen_string_literal: true
require_relative '../contact'

RSpec.describe Contact do
  it 'valida email e telefone corretos' do
    c = Contact.new(id: '1', name: 'Lenon', phone: '27999990000', email: 'lenon@example.com', birthday: '1990-01-01')
    expect(c.email).to eq('lenon@example.com')
    expect(c.phone).to eq('27999990000')
  end

  it 'rejeita email inválido' do
    expect {
      Contact.new(id: '1', name: 'Lenon', phone: '27999990000', email: 'invalido', birthday: nil)
    }.to raise_error(Contact::ValidationError)
  end

  it 'normaliza o telefone removendo não dígitos' do
    c = Contact.new(id: '1', name: 'L', phone: '(27) 99999-0000', email: 'l@x.com')
    expect(c.phone).to eq('27999990000')
  end
end
