local ElementoJuego = require("src.entities.ElementoJuego")

local Mejora = setmetatable({}, {__index = ElementoJuego})
Mejora.__index = Mejora

-- Recibe la función 'efecto' directamente, como indica la rúbrica 5.0
function Mejora.new(x, y, efecto, color, tipoNombre)
    local self = setmetatable(ElementoJuego.new(x, y, 32, 14), Mejora) -- Cápsula un poco más grande
    self.efecto = efecto
    self._color = color or {1, 0.5, 0.5}
    self.tipoNombre = tipoNombre or "Poder"
    self._dy = 150
    self._activa = true
    return self
end

function Mejora:actualizar(dt)
    self._y = self._y + self._dy * dt
    if self._y > love.graphics.getHeight() then
        self._activa = false
    end
end

function Mejora:dibujar()
    if self._activa then
        love.graphics.setColor(self._color) -- Color dinámico del powerup
        
        -- Dibujar cápsula (rectángulo con border radius igual a la mitad de la altura)
        love.graphics.rectangle("fill", self._x, self._y, self._ancho, self._alto, self._alto/2, self._alto/2)
        
        -- Pequeño brillo superior para dar efecto 3D
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.rectangle("fill", self._x + 4, self._y + 2, self._ancho - 8, self._alto/3, self._alto/4, self._alto/4)
        
        -- Dibujar ícono interno blanco dentro de la cápsula
        love.graphics.setColor(1, 1, 1, 0.9)
        local cx = self._x + self._ancho/2
        local cy = self._y + self._alto/2
        
        if self.tipoNombre == "+1 Vida" then
            -- Ícono de corazón
            love.graphics.circle("fill", cx-2, cy-1, 2)
            love.graphics.circle("fill", cx+2, cy-1, 2)
            love.graphics.polygon("fill", cx-4, cy, cx+4, cy, cx, cy+4)
        elseif self.tipoNombre == "+ Raqueta" then
            -- Ícono de raqueta
            love.graphics.rectangle("fill", cx-6, cy-1.5, 12, 3, 1, 1)
        elseif self.tipoNombre == "+ Bolas" then
            -- Ícono de 3 pelotitas
            love.graphics.circle("fill", cx, cy-2, 2.5)
            love.graphics.circle("fill", cx-5, cy+3, 2.5)
            love.graphics.circle("fill", cx+5, cy+3, 2.5)
        end
        
        -- Texto flotante animado indicando qué es
        local floatY = math.sin(love.timer.getTime() * 5) * 3 -- Movimiento oscilante
        local textX = self._x - 50 + self._ancho/2
        local textY = self._y - 22 + floatY
        
        love.graphics.setFont(gFuentes['peque'])
        
        -- Sombra del texto (negra) para legibilidad perfecta
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.printf(self.tipoNombre, textX + 1, textY + 1, 100, "center")
        
        -- Texto principal (color de la mejora)
        love.graphics.setColor(self._color)
        love.graphics.printf(self.tipoNombre, textX, textY, 100, "center")
    end
end

return Mejora
