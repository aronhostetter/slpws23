require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require_relative './model.rb'
enable :sessions

get('/') do
  slim(:index)
end

get('/skis') do
  id = session[:id].to_i
  @skis = select_all("skis")
  slim(:"skis/index")
end

get('/skis/new') do
  slim(:"skis/new")
end

post('/skis/new') do
  modelname = params[:modelname]
  brand = params[:brand]
  length = params[:length]
  frontwidth = params[:frontwidth]
  waistwidth = params[:waistwidth]
  tailwidth = params[:tailwidth]
  skitype = params[:skitype]

  insert_skis(brand,modelname,length,frontwidth,waistwidth,tailwidth,skitype)
  redirect('/skis')
  
  # user_id = session[:id].to_i
  # if content != " "
  # else
  #   session[:fault] = "ski name"
  #   redirect('fault')
  # end
end
  
post('/skis/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/slpws23.db")
  db.execute("DELETE FROM skis WHERE id = ?",id)
  redirect('/skis')
end


#   FORTSÄTT HÄR
post('/skis/:id/update') do
  id = params[:id].to_i
  content = params[:content]
  user_id = params[:user_id].to_i
  
  modelname = params[:modelname]
  brand = params[:brand]
  length = params[:length]
  frontwidth = params[:frontwidth]
  waistwidth = params[:waistwidth]
  tailwidth = params[:tailwidth]
  skitype = params[:skitype]
  
  update_skis(id,brand,modelname,length,frontwidth,waistwidth,tailwidth,skitype)
  redirect('/skis')

  # if content != " "
  #   db = SQLite3::Database.new("db/slpws23.db")
  #   db.execute("UPDATE skis SET content = ? WHERE id = ?",content,id)
  #   redirect('/skis')
  # else
  #   session[:fault] = "ski name"
  #   redirect('fault')
  # end
end

get('/skis/:id/edit') do
  @id = params[:id].to_i
  @ski = select_all_id("skis",@id)[0]
  slim(:"skis/edit")
end


# get('/helmets') do
#     id = session[:id].to_i
#     db = SQLite3::Database.new("db/slpws23.db")
#     db.results_as_hash = true
#     @helmets = db.execute("SELECT * FROM helmets")
#     # @helmets = select_all("helmets")
#     slim(:"helmets/index")
# end

# get('/helmets/new') do
#     slim(:"helmets/new")
# end