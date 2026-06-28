local Ladrillo = require("Ladrillo")

local Nivel = {}
Nivel.__index = Nivel

function Nivel.new(numeroNivel, dificultad, fondo)
    local self = setmetatable({}, Nivel)
    self.numeroNivel = numeroNivel or 1
    self.dificultad = dificultad or 1.0
    self.fondo = fondo or "default"
    self.ladrillos = {}
    return self
end

function Nivel:cargarConfiguracion()

end

function Nivel:esNivelCompletado()
    return false
end

return Nivel
