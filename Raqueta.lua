local ElementoJuego = require("ElementoJuego")

local Raqueta = setmetatable({}, {__index = ElementoJuego})
Raqueta.__index = Raqueta

function Raqueta.new(x, y, ancho, alto, velocidadX, color)
    local self = setmetatable(ElementoJuego.new(x, y, ancho, alto), Raqueta)
    self.velocidadX = velocidadX or 300
    self.color = color or "azul"
    return self
end

function Raqueta:actualizar(dt)

end

function Raqueta:dibujar()

end

return Raqueta
