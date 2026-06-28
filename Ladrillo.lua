local ElementoJuego = require("ElementoJuego")

local Ladrillo = setmetatable({}, {__index = ElementoJuego})
Ladrillo.__index = Ladrillo

function Ladrillo.new(x, y, ancho, alto, resistencia, color)
    local self = setmetatable(ElementoJuego.new(x, y, ancho, alto), Ladrillo)
    self.resistencia = resistencia or 1
    self.color = color or "rojo"
    self.destruido = false
    return self
end

function Ladrillo:actualizar()

end

function Ladrillo:dibujar()

end

function Ladrillo:recibirImpacto()

end

return Ladrillo
