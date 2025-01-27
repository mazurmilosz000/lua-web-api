local lapis = require("lapis")
local db = require("lapis.db")
local Model = require("lapis.db.model").Model

local Category = Model:extend("categories")

function Category:get_products()
  return self:has_many("products", { foreign_key = "category_id" })
end

local Product = Model:extend("products", {
  primary_key = "id", -- Klucz główny w tabeli products
})

return { Category = Category, Product = Product }




