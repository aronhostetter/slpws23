require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
require 'sinatra/reloader'
require_relative './model.rb'
enable :sessions

include Model
###     KVAR ATT GÖRAS
#       YARDOC


before do
  # Lista alla tillåtna routes
  allowed_paths_guest = ['/fault', '/', '/register', '/showlogin', '/login', '/users/new', '/users', '/skis', '/bindings', '/helmets']

  restricted_paths_user = ['/skis/new','/bindings/new','/helmets/new']

  # BEGRÄNSNINGAR FÖR GÄSTANVÄNDARE
  # Om användaren inte är inloggad och försöker komma åt en begränsad sökväg, omdirigera dem till inloggningssidan.	Här har session[:logged_in satts till “true” vid inloggning. 

  # BEGRÄNSNINGAR FÖR REGISTRERADE ANVÄNDARE
  # Om användaren är inloggad men inte är en administratör och försöker komma åt en administratörssökväg,
  # omdirigera dem till startsidan. Här har session[:admin] satts till “true” vid inloggningen.

  if session[:id] == nil && !allowed_paths_guest.include?(request.path_info)
    redirect '/showlogin'
  elsif session[:id] != 3 && restricted_paths_user.include?(request.path_info)
    session[:fault] = "Du har inte tillåtelse att ändra dessa resurser"
    redirect '/fault'
  end
end

# Displays an error message
#
get('/fault') do
  @faultmsg = session[:fault]
  session[:fault] = nil
  slim(:fault)
end

# Error 404 Page Not Found
#
not_found do
  session[:fault] = "404 Sidan finns inte."
  redirect('/fault')
end

# Display Landing Page
#
get('/') do
  slim(:index)
end

#     USERS

# Displays a register form
#
get('/register') do
  slim(:register)
end

# Displays a login form
#
get('/showlogin') do
  slim(:login)
end

# Attempts login and updates the session
# @param [String] password, The typed password
# @param [String] username, The typed username
# @see Model#cooldown
# @see Model#select_column
# @see Model#select_password
#
post('/login') do
  cooldown()

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

# Logout and updates the session
#
post('/logout') do
  session[:id] = nil
  session[:username] = nil
  redirect('/')
end

# Displays all users
# @see Model#select_all
#
get('/users') do
  @users = select_all("users")
  slim(:"users/index")
end

# Displays one users equipment
# @see Model#select_all_id
# @see Model#select_owned_bindings
# @see Model#select_owned_skis
# @see Model#select_owned_helmets
#
get('/users/:id') do
  id = params[:id].to_i
  @user = select_all_id("users",id)
  @bindings = select_owned_bindings(id)
  @skis = select_owned_skis(id)
  @helmets = select_owned_helmets(id)
  slim(:"users/show")
end

# Registers new user after register route
# @param [String] username, The typed username
# @param [String] password, The typed password  
# @param [String] password_confirm, A confirmation of the password
# @see Model#create_user
#
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
    redirect('/fault')
  end
end

#     USERS EDIT

# Shows and lets user change the owned inventory
# @see Model#select_owned_skis
# @see Model#select_owned_bindings
# @see Model#select_owned_helmets
# @see Model#select_all
#
get('/users/:id/edit') do
  ###   EFTERSOM HELA EDIT SIDAN BASERAS PÅ DEN INLOGGADE ANVÄNDARENS SESSION[:ID] SÅ KOMMER DET INTE GÅ ATT ÄNDRA ANDRAS RESURSER GENOM ATT ÄNDRA I SÖKVÄGEN. ALLTSÅ BEHÖVS INGEN CHECK AV ID HÄR.
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

# Registers new user after register route
# @param [Integer] path_id, The user-id in the search path
# @see Model#check_id
# @param [Integer] eq_id, The id of equipment that is affected by the previous form.
# @param [String] action, The wanted action from the previous form.
# @param [String] category, The category of the affected equipment.
# @param [String] user_id, The logged in user.
# @see Model#remove_from_equipment
# @see Model#add_to_equipment
#
post('/users/:id/update') do
  path_id = params[:id].to_i
  check_id(path_id)

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

# Registers new user after register route
# @param [String] id, The user-id in the search path
# @see Model#check_id
# @see Model#delete_all_id
#
post('/users/:id/delete') do
  id = params[:id].to_i
  if id == 3
    session[:fault] = "ADMIN kan inte tas bort från hemsidan"
    redirect('/fault')
  end
  check_id(id)
  delete_all_id("user",id)
  redirect('/users')
end

#     CRUD SKIS

#     SKIS VIEW

# Displays all skis
# @see Model#select_all
#
get('/skis') do
  @skis = select_all("skis")
  slim(:"skis/index")
end

#     SKIS GET NEW

# Displays form to add new skis to the website
#
get('/skis/new') do
  slim(:"skis/new")
end

#     SKIS  POST NEW

# Registers new ski after get route with form
# @param [String] modelname, The typed modelname
# @param [String] brand, The typed brand
# @param [Integer] length, The typed lenght
# @param [Integer] frontwidth, The typed frontwidth
# @param [Integer] waistwidth, The typed waistwidth
# @param [Integer] tailwidth, The typed tailwidth
# @param [String] skitype, The chosen skitype
# @see Model#check_input
# @see Model#check_input
# @see Model#insert_skis
#
post('/skis/new') do
  modelname = params[:modelname]
  brand = params[:brand]
  length = params[:length]
  frontwidth = params[:frontwidth]
  waistwidth = params[:waistwidth]
  tailwidth = params[:tailwidth]
  skitype = params[:skitype]

  check_input(modelname)
  check_input(brand)

  insert_skis(brand,modelname,skitype,length,frontwidth,waistwidth,tailwidth)
  redirect('/skis') 
end

#     SKIS DELETE

# Deletes skis from website
# @param [Integer] id, The user-id in the search path
# @see Model#check_id
# @see Model#delete_all_id
#
post('/skis/:id/delete') do
  id = params[:id].to_i
  check_id(id)
  delete_all_id("ski",id)
  redirect('/skis')
end

#     SKIS UPDATE

# Updates ski after get route with form
# @param [Integer] path_id, The user-id in the search path
# @param [String] modelname, The typed modelname
# @param [String] brand, The typed brand
# @param [Integer] length, The typed lenght
# @param [Integer] frontwidth, The typed frontwidth
# @param [Integer] waistwidth, The typed waistwidth
# @param [Integer] tailwidth, The typed tailwidth
# @param [String] skitype, The chosen skitype
# @see Model#check_id
# @see Model#check_input
# @see Model#check_input
# @see Model#update_skis
#
post('/skis/:id/update') do
  id = params[:id].to_i
  modelname = params[:modelname]
  brand = params[:brand]
  length = params[:length]
  frontwidth = params[:frontwidth]
  waistwidth = params[:waistwidth]
  tailwidth = params[:tailwidth]
  skitype = params[:skitype]
  
  check_id(id)
  check_input(modelname)
  check_input(brand)

  update_skis(id,brand,modelname,length,frontwidth,waistwidth,tailwidth,skitype)
  redirect('/skis')
end

#     SKIS EDIT

# Shows form to edit skis
# @param [Integer] @id, The user-id in the search path
# @see Model#check_id
# @see Model#select_all_id
#
get('/skis/:id/edit') do
  @id = params[:id].to_i
  @ski = select_all_id("skis",@id)[0]
  slim(:"skis/edit")
end

#     CRUD HELMETS
#
#     HELMETS  VIEW

# Displays all helmets
# @see Model#select_all
#
get('/helmets') do
  @helmets = select_all("helmets")
  slim(:"helmets/index")
end

#     HELMETS GET NEW

# Displays form to add new helmets to the website
#
get('/helmets/new') do
  slim(:"helmets/new")
end

#     HELMETS POST NEW

# Registers new helmet after get route with form
# @param [String] modelname, The typed modelname
# @param [String] brand, The typed brand
# @param [Integer] mips, The chosen mips alternative
# @param [String] color, The typed color
# @see Model#check_input
# @see Model#check_input
# @see Model#check_input
# @see Model#insert_helmets
#
post('/helmets/new') do
  modelname = params[:modelname]
  brand = params[:brand]
  mips = params[:mips]
  color = params[:color]

  check_input(modelname)
  check_input(brand)
  check_input(color)

  insert_helmets(brand,modelname,mips,color)
  redirect('/helmets')
end

#     HELMETS DELETE

# Deletes helmets from website
# @param [Integer] id, The user-id in the search path
# @see Model#check_id
# @see Model#delete_all_id
#
post('/helmets/:id/delete') do
  #   KOLLA SÅ ATT ID STÄMMER MED PARAMS INNAN DELETE
  id = params[:id].to_i
  check_id(id)
  delete_all_id("helmet",id)
  redirect('/helmets')
end

#     HELMETS UPDATE

# Updates helmet after get route with form
# @param [String] modelname, The typed modelname
# @param [String] brand, The typed brand
# @param [Integer] mips, The chosen mips alternative
# @param [String] color, The typed color
# @see Model#check_id
# @see Model#check_input
# @see Model#check_input
# @see Model#update_helmets
#
post('/helmets/:id/update') do
  id = params[:id].to_i
  modelname = params[:modelname]
  brand = params[:brand]
  mips = params[:mips]
  color = params[:color]
  
  check_id(id)
  check_input(modelname)
  check_input(brand)

  update_helmets(id,brand,modelname,mips,color)
  redirect('/helmets')
end

#     HELMETS EDIT

# Shows form to edit helmets
# @param [Integer] @id, The user-id in the search path
# @see Model#check_id
# @see Model#select_all_id
#
get('/helmets/:id/edit') do
  @id = params[:id].to_i
  @helmet = select_all_id("helmets",@id)[0]
  slim(:"helmets/edit")
end

#     CRUD bindings
#
#     BINDINGS  VIEW

# Displays all bindings
# @see Model#select_all
#
get('/bindings') do
  @bindings = select_all("bindings")
  slim(:"bindings/index")
end

#     BINDINGS  GET NEW

# Displays form to add new binding to the website
#
get('/bindings/new') do
  slim(:"bindings/new")
end

#     BINDINGS  POST NEW

# Registers new binding after get route with form
# @param [String] modelname, The typed modelname
# @param [String] brand, The typed brand
# @param [String] type, The chosen type
# @param [Integer] weight, The typed weight
# @see Model#check_input
# @see Model#check_input
# @see Model#insert_bindings
#
post('/bindings/new') do
  modelname = params[:modelname]
  brand = params[:brand]
  type = params[:type]
  weight = params[:weight]

  check_input(modelname)
  check_input(brand)

  insert_bindings(brand,modelname,type,weight)
  redirect('/bindings')
end

#     BINDINGS  DELETE

# Deletes bindings from website
# @param [Integer] id, The user-id in the search path
# @see Model#check_id
# @see Model#delete_all_id
#
post('/bindings/:id/delete') do
  id = params[:id].to_i
  delete_all_id("binding",id)
  redirect('/bindings')
end

#     BINDINGS UPDATE

# Updates binding after get route with form
# @param [String] modelname, The typed modelname
# @param [String] brand, The typed brand
# @param [Integer] mips, The chosen mips alternative
# @param [String] color, The typed color
# @see Model#check_id
# @see Model#check_input
# @see Model#update_bindings
#
post('/bindings/:id/update') do
  id = params[:id].to_i  
  modelname = params[:modelname]
  brand = params[:brand]
  type = params[:type]
  weight = params[:weight]
  
  check_id(id)
  check_input(modelname)
  check_input(brand)

  update_bindings(id,brand,modelname,type,weight)
  redirect('/bindings')
end

#     BINDINGS EDIT

# Shows form to edit helmets
# @param [Integer] @id, The user-id in the search path
# @see Model#check_id
# @see Model#select_all_id
#
get('/bindings/:id/edit') do
  @id = params[:id].to_i
  @binding = select_all_id("bindings",@id)[0]
  slim(:"bindings/edit")
end