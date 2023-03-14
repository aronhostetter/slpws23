#     CRUD HELMETS

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