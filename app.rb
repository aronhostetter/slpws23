require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require_relative './model.rb'
enable :sessions

#     HOME  ALL
get('/') do
  slim(:index)
end

#     CRUD SKIS

#     SKIS  VIEW
get('/skis') do
  id = session[:id].to_i
  @skis = select_all("skis")
  slim(:"skis/index")
end

#     SKIS  POST NEW
get('/skis/new') do
  slim(:"skis/new")
end

#     POST NEW
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

#     SKIS  DELETE
post('/skis/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/slpws23.db")
  db.execute("DELETE FROM skis WHERE id = ?",id)
  redirect('/skis')
end


#     SKIS UPDATE
post('/skis/:id/update') do
  id = params[:id].to_i  
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

#     SKIS EDIT
get('/skis/:id/edit') do
  @id = params[:id].to_i
  # ÅTGÄRDA ATT DET BLIR ARRAY I ARRAY NEDAN, FRÅGA EMIL
  @ski = select_all_id("skis",@id)[0]
  slim(:"skis/edit")
end

#     CRUD HELMETS
#
#     HELMETS  VIEW
get('/helmets') do
  id = session[:id].to_i
  @helmets = select_all("helmets")
  slim(:"helmets/index")
end

#     HELMETS  POST NEW
get('/helmets/new') do
  slim(:"helmets/new")
end

#     POST NEW
post('/helmets/new') do
  modelname = params[:modelname]
  brand = params[:brand]
  mips = params[:mips]
  color = params[:color]

  insert_helmets(brand,modelname,mips,color)
  redirect('/helmets')
end

#     HELMETS  DELETE
post('/helmets/:id/delete') do
  id = params[:id].to_i
  db = SQLite3::Database.new("db/slpws23.db")
  db.execute("DELETE FROM helmets WHERE id = ?",id)
  redirect('/helmets')
end

#     HELMETS UPDATE
post('/helmets/:id/update') do
  id = params[:id].to_i
  modelname = params[:modelname]
  brand = params[:brand]
  mips = params[:mips]
  color = params[:color]
  
  update_helmets(id,brand,modelname,mips,color)
  redirect('/helmets')
end

#     HELMETS EDIT
get('/helmets/:id/edit') do
  @id = params[:id].to_i
  # ÅTGÄRDA ATT DET BLIR ARRAY I ARRAY NEDAN, FRÅGA EMIL
  @helmet = select_all_id("helmets",@id)[0]
  slim(:"helmets/edit")
end