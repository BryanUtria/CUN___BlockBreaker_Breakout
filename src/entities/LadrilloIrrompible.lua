local Ladrillo = require("src.entities.Ladrillo")

local LadrilloIrrompible = setmetatable({}, {__index = Ladrillo})
LadrilloIrrompible.__index = LadrilloIrrompible

function LadrilloIrrompible.new(x, y, ancho, alto, color)
    local self = setmetatable(Ladrillo.new(x, y, ancho, alto, color), LadrilloIrrompible)
    self._color = color or {0.5, 0.5, 0.5}
    self._puntos = 0
    return self
end

function LadrilloIrrompible:alGolpear()
    -- Nunca se destruye, pero sí brilla cuando lo golpean
    self._brillo = 1
    return false
end

function LadrilloIrrompible:dibujar()
    if self._enJuego then
        -- Sombra paralela
        love.graphics.setColor(0, 0, 0, 0.6)
        love.graphics.rectangle("fill", self._x + 3, self._y + 4, self._ancho, self._alto, 6, 6)
        
        -- Efecto de parpadeo al ser golpeado
        local brilloAdicional = self._brillo * 0.8
        local r = self._color[1] + (1 - self._color[1]) * brilloAdicional
        local g = self._color[2] + (1 - self._color[2]) * brilloAdicional
        local b = self._color[3] + (1 - self._color[3]) * brilloAdicional
        
        -- Base del bloque de hierro (Bordes redondeados para mantener consistencia)
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", self._x, self._y, self._ancho, self._alto, 6, 6)
        
        -- Detalles metálicos (Placas interiores y remaches)
        love.graphics.setColor(r * 0.7, g * 0.7, b * 0.7, 1)
        -- Borde interior para darle profundidad
        love.graphics.rectangle("line", self._x + 4, self._y + 4, self._ancho - 8, self._alto - 8, 4, 4)
        
        -- Remaches en las esquinas
        love.graphics.setColor(r * 0.4, g * 0.4, b * 0.4, 1)
        love.graphics.rectangle("fill", self._x + 6, self._y + 6, 2, 2)
        love.graphics.rectangle("fill", self._x + self._ancho - 8, self._y + 6, 2, 2)
        love.graphics.rectangle("fill", self._x + 6, self._y + self._alto - 8, 2, 2)
        love.graphics.rectangle("fill", self._x + self._ancho - 8, self._y + self._alto - 8, 2, 2)
        
        -- Borde brillante de destello
        if self._brillo > 0 then
            love.graphics.setColor(1, 1, 1, self._brillo)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", self._x, self._y, self._ancho, self._alto, 6, 6)
        end
    end
end

return LadrilloIrrompible
