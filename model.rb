require 'sinatra/reloader'

###     GENERELL SQL

def select_all(category)
    # p category
    db = SQLite3::Database.new("db/slpws23.db")
    db.results_as_hash = true
    return db.execute("SELECT * FROM #{category}")
end

def select_all_id(category,id)
    # p category,id
    db = SQLite3::Database.new("db/slpws23.db")
    db.results_as_hash = true
    return db.execute("SELECT * FROM #{category} WHERE id = ?", id)
end

###     SKIS

def insert_skis(brand,modelname,skitype,length,frontwidth,waistwidth,tailwidth)
    # p brand,modelname,skitype,length,frontwidth,waistwidth,tailwidth
    db = SQLite3::Database.new("db/slpws23.db")
    db.execute("INSERT INTO skis (modelname,brand,length,frontwidth,waistwidth,tailwidth,skitype) VALUES (?,?,?,?,?,?,?)",modelname,brand,length,frontwidth,waistwidth,tailwidth,skitype)
end

def update_skis(id,brand,modelname,length,frontwidth,waistwidth,tailwidth,skitype)
    # p modelname,brand,length,frontwidth,waistwidth,tailwidth,skitype,id
    db = SQLite3::Database.new("db/slpws23.db")
    db.execute("UPDATE skis SET modelname = ?,brand = ?,length = ?,frontwidth = ?,waistwidth = ?,tailwidth = ?,skitype = ? WHERE id = ?",modelname,brand,length,frontwidth,waistwidth,tailwidth,skitype,id)
end

###     HELMETS

def insert_helmets(brand,modelname,mips,color)
    # p brand,modelname,mips,color
    db = SQLite3::Database.new("db/slpws23.db")
    db.execute("INSERT INTO helmets (modelname,brand,mips,color) VALUES (?,?,?,?)",modelname,brand,mips,color)
end

def update_helmets(id,brand,modelname,mips,color)
    # p modelname,brand,mips,color,id
    db = SQLite3::Database.new("db/slpws23.db")
    db.execute("UPDATE helmets SET modelname = ?,brand = ?,mips = ?,color = ? WHERE id = ?",modelname,brand,mips,color,id)
end