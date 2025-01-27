local lapis = require("lapis")
local app = lapis.Application()
local Category = require("models").Category
local Product = require("models").Product
local inspect = require("inspect")
local cjson = require("cjson")


app:get("/", function()
  return "Welcome to Lapis " .. require("lapis.version")
end)

-- POST: Dodanie nowej kategorii
app:post("/categories", function(self)
  print("Received parameters: ", inspect(self.params))
  ngx.req.read_body()
  
  local body_data = ngx.req.get_body_data()
  local decoded_data = cjson.decode(body_data)
  print("Decoded data: ", require("inspect")(decoded_data))

  local category_name = decoded_data.name
  print("Received category name: ", category_name)

  if not category_name or category_name == "" then
    return { status = 400, json = { error = "Category name is required" } }
  end
  local new_category = Category:create{
    name = category_name
  }
  return { json = new_category }
end)


-- GET: Zwrócenie wszystkich kategorii
app:get("/categories", function(self)
  local categories = Category:select()
  return { json = categories }
end)

-- GET: Zwrócenie kategorii po ID
app:get("/categories/:id", function(self)
  local category = Category:find(self.params.id)
  if not category then
    return { status = 404, json = { error = "Category not found" } }
  end
  return { json = category }
end)

-- PUT: Aktualizacja kategorii
app:put("/categories/:id", function(self)
  local category = Category:find(self.params.id)
  if not category then
    return { status = 404, json = { error = "Category not found" } }
  end

  ngx.req.read_body()

  local body_data = ngx.req.get_body_data()
  local decoded_data = cjson.decode(body_data)

 local category_name = decoded_data.name
  if not category_name or category_name == "" then
    return { status = 400, json = { error = "Category name is required" } }
  end

  category.name = category_name
  category:update({ name = category_name })

  return { json = category }
end)

-- DELETE: Usunięcie kategorii
app:delete("/categories/:id", function(self)
  local category = Category:find(self.params.id)
  if not category then
    return { status = 404, json = { error = "Category not found" } }
  end

  category:delete()
  return { status = 200, json = { message = "Category deleted" } }
end)


--- PRODUKTY
-- POST: Dodanie nowego produktu
app:post("/products", function(self)
  ngx.req.read_body()

  local body_data = ngx.req.get_body_data()
  local decoded_data = cjson.decode(body_data)

  local name = decoded_data.name
  local category_id = decoded_data.category_id
  local price = decoded_data.price

  if not name or name == "" then
    return { status = 400, json = { error = "Product name is required" } }
  end

  if not category_id or category_id == "" then
    return { status = 400, json = { error = "Category ID is required" } }
  end

  if not price or type(price) ~= "number" then
    return { status = 400, json = { error = "Price must be a number" } }
  end

  local new_product = Product:create{
    name = name,
    category_id = category_id,
    price = price
  }

  return { json = new_product }
end)

-- GET: Zwrócenie wszystkich produktów
app:get("/products", function(self)
  local products = Product:select()
  return { json = products }
end)

-- GET: Zwrócenie produktu po ID
app:get("/products/:id", function(self)
  local product = Product:find(self.params.id)
  if not product then
    return { status = 404, json = { error = "Product not found" } }
  end
  return { json = product }
end)

-- PUT: Aktualizacja produktu
app:put("/products/:id", function(self)
  local product = Product:find(self.params.id)
  if not product then
    return { status = 404, json = { error = "Product not found" } }
  end

  ngx.req.read_body()
  local body_data = ngx.req.get_body_data()
  local decoded_data = cjson.decode(body_data)

  local name = decoded_data.name
  local category_id = decoded_data.category_id
  local price = decoded_data.price

  if name then product.name = name end
  if category_id then product.category_id = category_id end
  if price then product.price = price end

  product:update({
    name = product.name,
    category_id = product.category_id,
    price = product.price
  })

  return { json = product }
end)

-- DELETE: Usunięcie produktu
app:delete("/products/:id", function(self)
  local product = Product:find(self.params.id)
  if not product then
    return { status = 404, json = { error = "Product not found" } }
  end

  product:delete()
  return { status = 200, json = { message = "Product deleted" } }
end)

return app
