local ElementoJuego = {}
ElementoJuego.__index = ElementoJuego

function ElementoJuego.new(x, y, ancho, alto)
    local self = setmetatable({}, ElementoJuego)
    self.posicionX = x or 0
    self.posicionY = y or 0
    self.ancho = ancho or 0
    self.alto = alto or 0
    return self
end

function ElementoJuego:actualizar()
    
end

function ElementoJuego:dibujar()
    
end

return ElementoJuego
