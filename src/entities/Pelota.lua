local ElementoJuego = require("src.entities.ElementoJuego")

local Pelota = setmetatable({}, {__index = ElementoJuego})
Pelota.__index = Pelota

function Pelota.new(x, y, ancho, alto, dx, dy, color)
    local self = setmetatable(ElementoJuego.new(x, y, ancho, alto), Pelota)
    self._dx = dx or 0
    self._dy = dy or 0
    self._color = color or {1, 1, 1}
    return self
end

function Pelota:actualizar(dt)
    self._x = self._x + self._dx * dt
    self._y = self._y + self._dy * dt
end

function Pelota:dibujar()
    love.graphics.setColor(self._color)
    love.graphics.circle("fill", self._x + self._ancho/2, self._y + self._alto/2, self._ancho/2)
end

function Pelota:rebotarEjeX()
    self._dx = -self._dx
end

function Pelota:rebotarEjeY()
    self._dy = -self._dy
end

return Pelota
