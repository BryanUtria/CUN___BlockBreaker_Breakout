local ElementoJuego = {}
ElementoJuego.__index = ElementoJuego

function ElementoJuego.new(x, y, ancho, alto)
    local self = setmetatable({}, ElementoJuego)
    self._x = x or 0
    self._y = y or 0
    self._ancho = ancho or 0
    self._alto = alto or 0
    return self
end

function ElementoJuego:colisiona(objetivo)
    -- AABB collision detection
    if self._x > objetivo._x + objetivo._ancho or objetivo._x > self._x + self._ancho then
        return false
    end
    if self._y > objetivo._y + objetivo._alto or objetivo._y > self._y + self._alto then
        return false
    end
    return true
end

function ElementoJuego:actualizar(dt)
end

function ElementoJuego:dibujar()
end

return ElementoJuego
