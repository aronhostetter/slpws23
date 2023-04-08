require 'sinatra'
require 'sinatra/reloader'

###     CONNECT TO DB
def connect_db()
    db = SQLite3::Database.new("db/slpws23.db")
    return db
end

###     GENERELL SQL

def select_all(category)
    # p category
    db = connect_db()
    db.results_as_hash = true
    return db.execute("SELECT * FROM #{category}")
end

def select_all_id(category,id)
    # p category,id
    db = connect_db()
    db.results_as_hash = true
    return db.execute("SELECT * FROM #{category} WHERE id = ?", id)
end

def delete_all_id(category,id)
    db = connect_db()
    return db.execute("DELETE FROM #{category} WHERE id = ?", id)
end

###     USERS

def create_user(username,pwdigest)
    db = connect_db()
    db.execute("INSERT INTO users (username,pwdigest) VALUES (?,?)",username,pwdigest)
end

def select_password(username)
    db = connect_db()
    db.results_as_hash = true
    result = db.execute("SELECT * FROM users WHERE username = ?",username).first
    return result
end

def remove_equipment(category,user_id,eq_id)
    db = connect_db()
    db.execute("DELETE FROM relations_user_#{category} WHERE user_id = ? AND ski_id = ?",user_id,eq_id)

end

def add_equipment(category,user_id,eq_id)
    db = connect_db()
    db.execute("INSERT INTO relations_user_#{category} (user_id,eq_id) VALUES (?,?)",user_id,eq_id)

end

###     SKIS

def insert_skis(brand,modelname,skitype,length,frontwidth,waistwidth,tailwidth)
    # p brand,modelname,skitype,length,frontwidth,waistwidth,tailwidth
    db = connect_db()
    db.execute("INSERT INTO skis (modelname,brand,length,frontwidth,waistwidth,tailwidth,skitype) VALUES (?,?,?,?,?,?,?)",modelname,brand,length,frontwidth,waistwidth,tailwidth,skitype)
end

def update_skis(id,brand,modelname,length,frontwidth,waistwidth,tailwidth,skitype)
    p modelname,brand,length,frontwidth,waistwidth,tailwidth,skitype,id
    db = connect_db()
    db.execute("UPDATE skis SET modelname = ?,brand = ?,length = ?,frontwidth = ?,waistwidth = ?,tailwidth = ?,skitype = ? WHERE id = ?",modelname,brand,length,frontwidth,waistwidth,tailwidth,skitype,id)
end

def select_owned_skis(id)
    db = connect_db()
    db.results_as_hash = true
    result = db.execute("
    SELECT skis.modelname,skis.brand,skis.length,skis.frontwidth,skis.waistwidth,skis.tailwidth,skis.skitype,skis.img_source
    FROM ((relations_user_ski
        INNER JOIN users ON relations_user_ski.user_id = users.id)
        INNER JOIN skis ON relations_user_ski.ski_id = skis.id)
    WHERE user_id = ?",id)
    return result
end

def select_available_skis(id)
    db = connect_db()
    db.results_as_hash = true
    result = db.execute("
    SELECT skis.modelname,skis.brand,skis.length,skis.frontwidth,skis.waistwidth,skis.tailwidth,skis.skitype,skis.img_source
    FROM ((relations_user_ski
        INNER JOIN users ON relations_user_ski.user_id = users.id)
        INNER JOIN skis ON relations_user_ski.ski_id = skis.id)
    WHERE user_id != ?",id)
    return result
end

###     HELMETS

def insert_helmets(brand,modelname,mips,color)
    # p brand,modelname,mips,color
    db = connect_db()
    db.execute("INSERT INTO helmets (modelname,brand,mips,color) VALUES (?,?,?,?)",modelname,brand,mips,color)
end

def update_helmets(id,brand,modelname,mips,color)
    # p modelname,brand,mips,color,id
    db = connect_db()
    db.execute("UPDATE helmets SET modelname = ?,brand = ?,mips = ?,color = ? WHERE id = ?",modelname,brand,mips,color,id)
end

def select_owned_helmets(id)
    db = connect_db()
    db.results_as_hash = true
    result = db.execute("
    SELECT helmets.modelname,helmets.brand,helmets.mips,helmets.color,helmets.img_source
    FROM ((relations_user_helmet
        INNER JOIN users ON relations_user_helmet.user_id = users.id)
        INNER JOIN helmets ON relations_user_helmet.helmet_id = helmets.id)
    WHERE user_id = ?",id)
    return result
end

def select_available_helmets(id)
    db = connect_db()
    db.results_as_hash = true
    result = db.execute("
    SELECT helmets.modelname,helmets.brand,helmets.mips,helmets.color,helmets.img_source
    FROM ((relations_user_helmet
        INNER JOIN users ON relations_user_helmet.user_id = users.id)
        INNER JOIN helmets ON relations_user_helmet.helmet_id = helmets.id)
    WHERE user_id != ?",id)
    return result
end

###     BINDINGS

def insert_bindings(brand,modelname,type,weight)
    # p brand,modelname,type,weight
    db = connect_db()
    db.execute("INSERT INTO bindings (modelname,brand,type,weight) VALUES (?,?,?,?)",modelname,brand,type,weight)
end

def update_bindings(id,brand,modelname,type,weight)
    # p id,brand,modelname,type,weight
    db = connect_db()
    db.execute("UPDATE bindings SET modelname = ?,brand = ?,type = ?,weight = ? WHERE id = ?",modelname,brand,type,weight,id)
end

def select_owned_bindings(id)
        db = connect_db()
        db.results_as_hash = true
        result = db.execute("
        SELECT bindings.modelname,bindings.brand,bindings.type,bindings.weight,bindings.img_source
        FROM ((relations_user_binding
            INNER JOIN users ON relations_user_binding.user_id = users.id)
            INNER JOIN bindings ON relations_user_binding.binding_id = bindings.id)
        WHERE user_id = ?",id)
        return result
end

def select_available_bindings(id)
        db = connect_db()
        db.results_as_hash = true
        result = db.execute("
        SELECT bindings.modelname,bindings.brand,bindings.type,bindings.weight,bindings.img_source
        FROM ((relations_user_binding
            INNER JOIN users ON relations_user_binding.user_id = users.id)
            INNER JOIN bindings ON relations_user_binding.binding_id = bindings.id)
        WHERE user_id != ?",id)
        return result
end