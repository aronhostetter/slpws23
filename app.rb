require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require_relative './model.rb'
enable :sessions

get('/') do
    slim(:register)
end

get('/skis') do
    id = session[:id].to_i
    db = SQLite3::Database.new("db/todo2022.db")
    db.results_as_hash = true
    @skis = db.execute("SELECT * FROM skis WHERE user_id = ?",id)
    slim(:"skis/index")
end