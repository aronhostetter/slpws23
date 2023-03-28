#     BINDINGS  POST NEW
get('/bindings/new') do
  slim(:"bindings/new")
end

#     POST NEW
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
  @ski = select_all_id("bindings",@id)[0]
  slim(:"bindings/edit")
end