local ElementoJuego = require("src.entities.ElementoJuego")

local Raqueta = setmetatable({}, {__index = ElementoJuego})
Raqueta.__index = Raqueta

function Raqueta.new(x, y, ancho, alto, velocidad, color)
    local self = setmetatable(ElementoJuego.new(x, y, ancho, alto), Raqueta)
    self._dx = velocidad or 400
    self._color = color or {0.2, 0.6, 1}
    self._brillo = 0 -- Nivel de brillo al ser golpeada
    return self
end

function Raqueta:actualizar(dt)
    if love.keyboard.isDown("left") then
        self._x = math.max(0, self._x - self._dx * dt)
    elseif love.keyboard.isDown("right") then
        self._x = math.min(love.graphics.getWidth() - self._ancho, self._x + self._dx * dt)
    end
    
    if self._brillo > 0 then
        self._brillo = math.max(0, self._brillo - dt * 4)
    end
end

function Raqueta:dibujar()
    -- El radio de los bordes será la mitad del alto para crear una forma de "cápsula" perfecta
    local radio = self._alto / 2
    
    -- Sombra paralela (Drop shadow) para dar realce
    love.graphics.setColor(0, 0, 0, 0.6)
    love.graphics.rectangle("fill", self._x + 4, self._y + 6, self._ancho, self._alto, radio, radio)
    
    -- Sombra o borde exterior grueso
    love.graphics.setColor(self._color[1] * 0.5, self._color[2] * 0.5, self._color[3] * 0.5, 1)
    love.graphics.rectangle("fill", self._x - 2, self._y - 2, self._ancho + 4, self._alto + 4, radio, radio)

    -- Cuerpo principal de la raqueta
    love.graphics.setColor(self._color)
    love.graphics.rectangle("fill", self._x, self._y, self._ancho, self._alto, radio, radio)
    
    -- Brillo interno / Núcleo que se enciende al golpear
    if self._brillo > 0 and self._ancho > 20 and self._alto > 8 then
        love.graphics.setColor(1, 1, 1, self._brillo * 0.8) 
        love.graphics.rectangle("fill", self._x + 10, self._y + 3, self._ancho - 20, self._alto - 6, (self._alto-6)/2, (self._alto-6)/2)
    end
end

return Raqueta
