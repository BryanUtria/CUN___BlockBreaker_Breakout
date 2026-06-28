local ElementoJuego = require("ElementoJuego")

local Pelota = setmetatable({}, {__index = ElementoJuego})
Pelota.__index = Pelota

function Pelota.new(x, y, ancho, alto, velocidadX, velocidadY, radio, color)
    local self = setmetatable(ElementoJuego.new(x, y, ancho, alto), Pelota)
    self.velocidadX = velocidadX or 0
    self.velocidadY = velocidadY or 0
    self.radio = radio or 5
    self.color = color or "blanco"
    return self
end

function Pelota:actualizar()

end

function Pelota:dibujar()

end

function Pelota:rebotar(eje)

end

return Pelota
