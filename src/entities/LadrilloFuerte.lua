local Ladrillo = require("src.entities.Ladrillo")

local LadrilloFuerte = setmetatable({}, {__index = Ladrillo})
LadrilloFuerte.__index = LadrilloFuerte

function LadrilloFuerte.new(x, y, ancho, alto, color1, color2)
    local self = setmetatable(Ladrillo.new(x, y, ancho, alto, color1), LadrilloFuerte)
    
    -- Usamos el color vibrante que ya generó Ladrillo.new si no le pasamos color1
    self._colorFuerte = color1 or {self._color[1], self._color[2], self._color[3]}
    
    -- El color débil (después de 1 golpe) será una versión más desaturada/clara del mismo color
    self._colorDebil = color2 or {
        (self._colorFuerte[1] + 1) / 2, 
        (self._colorFuerte[2] + 1) / 2, 
        (self._colorFuerte[3] + 1) / 2
    }
    
    self._color = self._colorFuerte
    self._puntos = 200
    self._golpes = 2
    return self
end

function LadrilloFuerte:alGolpear()
    self._golpes = self._golpes - 1
    if self._golpes <= 0 then
        self._enJuego = false
        return true
    else
        self._color = self._colorDebil
        self._brillo = 1 -- Brilla intensamente al recibir el primer golpe
        return false
    end
end

return LadrilloFuerte
