require 'sinatra/reloader'

def select_all(category)
    db = SQLite3::Database.new("db/slpws23.db")
    db.results_as_hash = true
    return db.execute("SELECT * FROM #{category}")
end

def insert_skis(brand,modelname,skitype,length,frontwidth,waistwidth,tailwidth)
    db = SQLite3::Database.new("db/slpws23.db")
    db.execute("INSERT INTO skis (modelname,brand,length,frontwidth,waistwidth,tailwidth,skitype) VALUES (?,?,?,?,?,?,?)",modelname,brand,length,frontwidth,waistwidth,tailwidth,skitype)
end

def select_all_id(category,id)
    db = SQLite3::Database.new("db/slpws23.db")
    db.results_as_hash = true
    return db.execute("SELECT * FROM #{category} WHERE id = ?", id)
end

#   INTE KLART
def update_skis(brand,modelname,skitype,length,frontwidth,waistwidth,tailwidth)
    db = SQLite3::Database.new("db/slpws23.db")
    db.execute("INSERT INTO skis (modelname,brand,length,frontwidth,waistwidth,tailwidth,skitype) VALUES (?,?,?,?,?,?,?)",modelname,brand,length,frontwidth,waistwidth,tailwidth,skitype)
end