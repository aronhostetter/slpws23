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

#     USERS

get('/register') do
  slim(:register)
end

get('/showlogin') do
  slim(:login)
end

post('/login') do
  username = params[:username]
  password = params[:password]
  db = SQLite3::Database.new("db/slpws23.db")
  db.results_as_hash = true
  result = db.execute("SELECT * FROM users WHERE username = ?",username).first
  pwdigest = result["pwdigest"]
  id = result["id"]
  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    session[:username] = username
    redirect('/todos')
  # else
    # session[:fault] = "login"
    # redirect('fault')
  end
end

post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if (password == password_confirm)
    #lägg till ny användare
    password_digest = BCrypt::Password.create(password)
    create_user(password_digest)
    db = SQLite3::Database.new("db/slpws23.db")
    db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,password_digest)
    redirect('/showlogin')
  # else
  #   session[:fault] = "register user"
  #   redirect('fault')
  end
end

#     CRUD SKIS

#     SKIS VIEW
get('/skis') do
  id = session[:id].to_i
  @skis = select_all("skis")
  slim(:"skis/index")
end

#     SKIS GET NEW
get('/skis/new') do
  slim(:"skis/new")
end

#     SKIS  POST NEW
post('/skis/new') do
  modelname = params[:modelname]
  brand = params[:brand]
  length = params[:length]
  frontwidth = params[:frontwidth]
  waistwidth = params[:waistwidth]
  tailwidth = params[:tailwidth]
  skitype = params[:skitype]

  insert_skis(brand,modelname,skitype,length,frontwidth,waistwidth,tailwidth)
  redirect('/skis')
  
  # user_id = session[:id].to_i
  # if content != " "
  # else
  #   session[:fault] = "ski name"
  #   redirect('fault')
  # end
end

#     SKIS DELETE
post('/skis/:id/delete') do
  id = params[:id].to_i
  delete_all_id("skis",id)
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

#     HELMETS GET NEW
get('/helmets/new') do
  slim(:"helmets/new")
end

#     HELMETS POST NEW
post('/helmets/new') do
  modelname = params[:modelname]
  brand = params[:brand]
  mips = params[:mips]
  color = params[:color]

  insert_helmets(brand,modelname,mips,color)
  redirect('/helmets')
end

#     HELMETS DELETE
post('/helmets/:id/delete') do
  id = params[:id].to_i
  delete_all_id("helmets",id)
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

#     CRUD bindings
#
#     BINDINGS  VIEW
get('/bindings') do
  id = session[:id].to_i
  @bindings = select_all("bindings")
  slim(:"bindings/index")
end

#     BINDINGS  GET NEW
get('/bindings/new') do
  slim(:"bindings/new")
end

#     BINDINGS  POST NEW
post('/bindings/new') do
  modelname = params[:modelname]
  brand = params[:brand]
  type = params[:type]
  weight = params[:weight]

  insert_bindings(brand,modelname,type,weight)
  redirect('/bindings')
end

#     BINDINGS  DELETE
post('/bindings/:id/delete') do
  id = params[:id].to_i
  delete_all_id("bindings",id)
  redirect('/bindings')
end

#     BINDINGS UPDATE
post('/bindings/:id/update') do
  id = params[:id].to_i  
  modelname = params[:modelname]
  brand = params[:brand]
  type = params[:type]
  weight = params[:weight]
  
  update_bindings(id,brand,modelname,type,weight)
  redirect('/bindings')
end

#     BINDINGS EDIT
get('/bindings/:id/edit') do
  @id = params[:id].to_i
  # ÅTGÄRDA ATT DET BLIR ARRAY I ARRAY NEDAN, FRÅGA EMIL
  @binding = select_all_id("bindings",@id)[0]
  slim(:"bindings/edit")
end