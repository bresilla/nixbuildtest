local muros = require("muros")

muros.cache = { default = "packages", pin = false }
muros.recipe { name = "checks", attribute = "checks" }
