local GestorPuntuacion = {}
GestorPuntuacion.__index = GestorPuntuacion

function GestorPuntuacion.new()
    local self = setmetatable({}, GestorPuntuacion)
    self.puntosActuales = 0
    self.recordMaximo = 0
    self.multiplicador = 1.0
    return self
end

function GestorPuntuacion:sumarPuntos(cantidad)
    
end

function GestorPuntuacion:resetear()
    
end

function GestorPuntuacion:obtenerPuntuacionFormateada()
    return tostring(self.puntosActuales)
end

return GestorPuntuacion
