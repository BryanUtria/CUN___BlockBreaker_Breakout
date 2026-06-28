local Pelota = require("Pelota")
local GestorPuntuacion = require("GestorPuntuacion")
local Nivel = require("Nivel")
local Raqueta = require("Raqueta")

local CampoJuego = {}
CampoJuego.__index = CampoJuego

function CampoJuego.new(ancho, alto)
    local self = setmetatable({}, CampoJuego)
    self.ancho = ancho or 800
    self.alto = alto or 600
    self.enEjecucion = false
    
    self.raqueta = Raqueta.new()
    self.pelota = Pelota.new()
    self.gestorPuntuacion = GestorPuntuacion.new()
    self.niveles = {}
    self.nivelActual = nil
    
    return self
end

function CampoJuego:iniciar()
    self.enEjecucion = true
end

function CampoJuego:verificarColisiones()

end

function CampoJuego:cambiarNivel(nuevoNivel)
    self.nivelActual = nuevoNivel
end

return CampoJuego
