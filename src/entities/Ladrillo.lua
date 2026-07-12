local ElementoJuego = require("src.entities.ElementoJuego")

local Ladrillo = setmetatable({}, {__index = ElementoJuego})
Ladrillo.__index = Ladrillo

function Ladrillo.new(x, y, ancho, alto, color)
    local self = setmetatable(ElementoJuego.new(x, y, ancho, alto), Ladrillo)
    
    -- Si no nos dan un color, asignamos uno vibrante basado en la fila (posición Y)
    if not color then
        local fila = math.floor((y - 40) / 20)
        local coloresVivos = {
            {1, 0.2, 0.3}, -- Rosa/Rojo Neón
            {1, 0.6, 0.1}, -- Naranja Vibrante
            {0.2, 0.9, 0.2}, -- Verde Lima
            {0.2, 0.7, 1},   -- Azul Celeste
            {0.8, 0.2, 1},   -- Púrpura Neón
            {1, 0.9, 0.1}    -- Amarillo Brillante
        }
        self._color = coloresVivos[(math.abs(fila) % #coloresVivos) + 1]
    else
        self._color = color
    end
    
    self._enJuego = true
    self._puntos = 100
    self._brillo = 0 -- Brillo al ser golpeado
    return self
end

function Ladrillo:actualizar(dt)
    if self._brillo > 0 then
        self._brillo = math.max(0, self._brillo - dt * 4) -- Se apaga en 0.25 seg
    end
end

function Ladrillo:dibujar()
    if self._enJuego then
        -- 0. Sombra paralela para dar realce (separación del fondo)
        love.graphics.setColor(0, 0, 0, 0.5)
        love.graphics.rectangle("fill", self._x + 3, self._y + 4, self._ancho, self._alto, 6, 6)
        
        -- Cuando recibe un golpe (_brillo > 0), su color se mezcla con blanco
        local r = self._color[1] + (1 - self._color[1]) * self._brillo * 0.8
        local g = self._color[2] + (1 - self._color[2]) * self._brillo * 0.8
        local b = self._color[3] + (1 - self._color[3]) * self._brillo * 0.8
        
        -- 1. Base oscura del ladrillo (Efecto 3D / Sombra)
        love.graphics.setColor(r * 0.5, g * 0.5, b * 0.5, 1)
        love.graphics.rectangle("fill", self._x, self._y, self._ancho, self._alto, 6, 6)
        
        -- 2. Capa principal brillante
        love.graphics.setColor(r, g, b, 1)
        love.graphics.rectangle("fill", self._x + 2, self._y + 2, self._ancho - 4, self._alto - 4, 4, 4)
        
        -- 3. Reflejo de cristal en la mitad superior
        love.graphics.setColor(1, 1, 1, 0.3)
        love.graphics.rectangle("fill", self._x + 4, self._y + 2, self._ancho - 8, (self._alto - 4) / 2, 4, 4)
        
        -- 4. Borde destellante intenso SÓLO al recibir impacto
        if self._brillo > 0 then
            love.graphics.setColor(1, 1, 1, self._brillo)
            love.graphics.setLineWidth(2)
            love.graphics.rectangle("line", self._x, self._y, self._ancho, self._alto, 6, 6)
        end
    end
end

-- Polimorfismo
function Ladrillo:alGolpear()
    self._enJuego = false
    return true -- Indica que fue destruido
end

return Ladrillo
