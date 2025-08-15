# frozen_string_literal: true
require 'sinatra'
require 'json'
require_relative '../agenda'

set :bind, '0.0.0.0'
set :port, 4567

AGENDA = Agenda.new

get '/contacts' do
  content_type :json
  order = params['order'] == 'birthday' ? :birthday : :name
  AGENDA.all(order: order).map(&:to_h).to_json
end

post '/contacts' do
  payload = JSON.parse(request.body.read) rescue {}
  begin
    c = AGENDA.add(**payload.transform_keys(&:to_sym))
    status 201
    c.to_h.to_json
  rescue => e
    status 422
    { error: e.message }.to_json
  end
end
