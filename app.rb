require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require_relative './model.rb'
enable :sessions

include Model
###     KVAR ATT GÖRAS
#       BEFORE-BLOCK OCH BEHÖRIGHETSSYSTEM
#       YARDOC
#       LOGGNING AV INLOGGNINGSFÖRSÖK
#       COOLDOWN

before do
  p "nu körs before blocket"
  # Lista alla begränsade routes
  restricted_paths_guest = ['/users/1/edit', '/skis/:id/edit', '/bindings/:id/edit', '/helmets/:id/edit']
  # restricted_paths_guest = []

  ###   SKAPAS PROBLEM NÄR DEN INTE VILL ACCEPTERA DUBBELFNUTTAR, JAG MÅSTE ANVÄNDA DET FÖR ATT KUNNA KOLLA VILKA DYNAMISKA ROUTES SOM JAG MÅSTE BEGRÄNSA FÖR OINLOGGADE ANVÄNDARE.

  ###   GÖRA TILLÅTNA ROUTES ISTÄLLET, DÅ KOMMER SAMMA

  # i = 1
  # while i < 10
  #   restricted_paths_guest.append('users/')
  #   restricted_paths_guest[i-1] += "#{i}"
  #   restricted_paths_guest[i-1] += '/edit'
  #   p "utfört"
  #   # p restricted_paths_guest[i-1]
  #   # p restricted_paths_guest
  #   i += 1
  # end
  # p restricted_paths_guest

  restricted_paths_user = ['skis/new','bindings/new','helmets/new']

  # BEGRÄNSNINGAR FÖR GÄSTANVÄNDARE
  # Om användaren inte är inloggad och försöker komma åt en begränsad sökväg, omdirigera dem till inloggningssidan.	Här har session[:logged_in satts till “true” vid inloggning. 

  if session[:id] == nil && restricted_paths_guest.include?(request.path_info)
    p "jag är gästanvändare"
    redirect '/showlogin'
  end

  # BEGRÄNSNINGAR FÖR REGISTRERADE ANVÄNDARE
  # Om användaren är inloggad men inte är en administratör och försöker komma åt en administratörssökväg,
  # omdirigera dem till startsidan. Här har session[:admin] satts till “true” vid inloggningen.

  if session[:id] != 3 && restricted_paths_user.include?(request.path_info)
    redirect '/'
  end
end

get('/fault') do
  @faultmsg = session[:fault]
  session[:fault] = nil
  slim(:fault)
end

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

  userarray = select_column("users","username")
  @usernames = []
  userarray.each do |user|
    @usernames<<user[0]
  end
  if !@usernames.include?(username)
    session[:fault] = "Ditt användarnamn finns inte registrerat på hemsidan, försök igen."
    redirect('/fault')
  end

  result = select_password(username)
  pwdigest = result["pwdigest"]
  id = result["id"]

  if BCrypt::Password.new(pwdigest) == password
    session[:id] = id
    session[:username] = username
    redirect('/')
  else
    session[:fault] = "Ditt användarnamn och lösenord stämde inte överens, försök igen."
    redirect('/fault')
  end
end

post('/logout') do
  session[:id] = nil
  session[:username] = nil
  redirect('/')
end

get('/users') do
  @users = select_all("users")
  slim(:"users/index")
end

get('/users/:id') do
  id = params[:id].to_i
  @user = select_all_id("users",id)
  @bindings = select_owned_bindings(id)
  @skis = select_owned_skis(id)
  @helmets = select_owned_helmets(id)
  slim(:"users/show")
end

post('/users/new') do
  username = params[:username]
  password = params[:password]
  password_confirm = params[:password_confirm]

  if (password == password_confirm)
    #lägg till ny användare
    pwdigest = BCrypt::Password.create(password)
    create_user(username,pwdigest)
    redirect('/showlogin')
  else
    session[:fault] = "Fälten för lösenord stämde inte överens, försök igen."
    redirect('fault')
  end
end

#     USERS EDIT
get('/users/:id/edit') do
  path_id = params[:id].to_i
  check_id(path_id)

  ### KOLLA SÅ ATT IDn STÄMMER INNAN ÄNDRING
  @ownedskis = select_owned_skis(session[:id])
  @ownedbindings = select_owned_bindings(session[:id])
  @ownedhelmets = select_owned_helmets(session[:id])

  @allskis = select_all("skis")
  @allbindings = select_all("bindings")
  @allhelmets = select_all("helmets")

  @avlb_skis = @allskis-@ownedskis
  @avlb_bindings = @allbindings-@ownedbindings
  @avlb_helmets = @allhelmets-@ownedhelmets

  slim(:"users/edit")
end

#     USER UPDATE
post('/users/:id/update') do
  # KOLLA SÅ ATT SESSION[:ID] STÄMMER MED ROUTE-ID INNAN KÖRS
  path_id = params[:id].to_i
  check_id(path_id)

  id = params[:id].to_i
  eq_id = params[:eq_id].to_i
  action = params[:action]
  category = params[:category]
  
  user_id = session[:id]

  if action == "remove"
    remove_from_equipment(category,user_id,eq_id)
  elsif action == "add"
    add_to_equipment(category,user_id,eq_id)
  end

  redirect("/users/#{user_id}/edit")
end

#     USERS DELETE
post('/users/:id/delete') do
  #   KOLLA SÅ ATT ID STÄMMER MED PARAMS INNAN DELETE
  #   KOLLA ÄVEN SÅ ATT USER INTE ÄR ADMIN
  id = params[:id].to_i
  delete_all_id("user",id)
  redirect('/users')
end

#     CRUD SKIS

#     SKIS VIEW
get('/skis') do
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
  #   KOLLA SÅ ATT ID STÄMMER MED PARAMS INNAN DELETE
  id = params[:id].to_i
  delete_all_id("ski",id)
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
  p @ski
  @ski = select_all_id("skis",@id)[0]
  slim(:"skis/edit")
end

#     CRUD HELMETS
#
#     HELMETS  VIEW
get('/helmets') do
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
  #   KOLLA SÅ ATT ID STÄMMER MED PARAMS INNAN DELETE
  id = params[:id].to_i
  delete_all_id("helmet",id)
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
  #   KOLLA SÅ ATT ID STÄMMER MED PARAMS INNAN DELETE
  id = params[:id].to_i
  delete_all_id("binding",id)
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