local Ladrillo = require("src.entities.Ladrillo")
local LadrilloFuerte = require("src.entities.LadrilloFuerte")
local LadrilloIrrompible = require("src.entities.LadrilloIrrompible")
local datosNiveles = require("data.niveles")

local Nivel = {}
Nivel.__index = Nivel

function Nivel.new(numeroNivel)
    local self = setmetatable({}, Nivel)
    self.ladrillos = {}
    self:cargarConfiguracion(numeroNivel)
    return self
end

function Nivel:cargarConfiguracion(numero)
    local configuracion = datosNiveles[numero]
    if not configuracion then return end
    
    local margenX = 50
    local margenY = 50
    local anchoLadrillo = (love.graphics.getWidth() - margenX * 2) / configuracion.columnas
    local altoLadrillo = 25
    
    for y = 1, configuracion.filas do
        for x = 1, configuracion.columnas do
            local tipo = configuracion.matriz[y][x]
            local pos_x = margenX + (x - 1) * anchoLadrillo
            local pos_y = margenY + (y - 1) * altoLadrillo
            
            -- Margen entre ladrillos de 2 píxeles (-2 en el ancho/alto)
            if tipo == 1 then
                table.insert(self.ladrillos, Ladrillo.new(pos_x, pos_y, anchoLadrillo - 2, altoLadrillo - 2))
            elseif tipo == 2 then
                table.insert(self.ladrillos, LadrilloFuerte.new(pos_x, pos_y, anchoLadrillo - 2, altoLadrillo - 2))
            elseif tipo == 3 then
                table.insert(self.ladrillos, LadrilloIrrompible.new(pos_x, pos_y, anchoLadrillo - 2, altoLadrillo - 2))
            end
        end
    end
end

function Nivel:esNivelCompletado()
    for _, ladrillo in ipairs(self.ladrillos) do
        -- Si hay al menos un ladrillo rompible que siga en juego
        if ladrillo._enJuego and ladrillo._puntos > 0 then
            return false
        end
    end
    return true
end

function Nivel:obtenerAvance()
    local total = 0
    local rotos = 0
    for _, ladrillo in ipairs(self.ladrillos) do
        if ladrillo._puntos > 0 then
            total = total + 1
            if not ladrillo._enJuego then
                rotos = rotos + 1
            end
        end
    end
    if total == 0 then return 100 end
    return math.floor((rotos / total) * 100)
end

function Nivel:dibujar()
    for _, ladrillo in ipairs(self.ladrillos) do
        ladrillo:dibujar()
    end
end

return Nivel
