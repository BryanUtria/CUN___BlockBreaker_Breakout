local EstadoBase = require("src.states.EstadoBase")
local Raqueta = require("src.entities.Raqueta")
local Pelota = require("src.entities.Pelota")
local Nivel = require("src.levels.Nivel")

local EstadoSaque = setmetatable({}, {__index = EstadoBase})
EstadoSaque.__index = EstadoSaque

function EstadoSaque.new()
    return setmetatable(EstadoBase.new(), EstadoSaque)
end

function EstadoSaque:entrar(params)
    self.vidas = params.vidas
    self.puntuacion = params.puntuacion
    self.nivel = params.nivel

    -- Inicializamos raqueta y pelota para este nivel si no existen
    self.raqueta = params.raqueta or Raqueta.new(love.graphics.getWidth()/2 - 50, love.graphics.getHeight() - 40, 100, 15)
    -- Hacer la pelota el doble de grande (16x16)
    self.pelota = params.pelota or Pelota.new(self.raqueta._x + self.raqueta._ancho/2 - 8, self.raqueta._y - 16, 16, 16)
    
    -- Inicializar nivel
    self.mapaNivel = params.mapaNivel or Nivel.new(self.nivel)
    
    -- Pegamos la pelota a la raqueta
    self.pelota._x = self.raqueta._x + (self.raqueta._ancho / 2) - (self.pelota._ancho / 2)
    self.pelota._y = self.raqueta._y - self.pelota._alto
    self.pelota._dx = 0
    self.pelota._dy = 0
end

function EstadoSaque:actualizar(dt)
    self.raqueta:actualizar(dt)
    -- La pelota sigue a la raqueta
    self.pelota._x = self.raqueta._x + (self.raqueta._ancho / 2) - (self.pelota._ancho / 2)

    if love.keyboard.fuePresionada("space") then
        self.pelota._dx = math.random(-80, 80) -- Un poco más de ángulo horizontal inicial
        self.pelota._dy = -350 -- Antes era -200, ahora irá mucho más rápido
        gMaquinaEstados:cambiar("jugar", {
            raqueta = self.raqueta,
            pelota = self.pelota,
            mapaNivel = self.mapaNivel,
            vidas = self.vidas,
            puntuacion = self.puntuacion,
            nivel = self.nivel
        })
    end
end

function EstadoSaque:dibujar()
    -- Dibujar el fondo global (compartido con la partida)
    gDibujarFondoJuego()
    
    self.mapaNivel:dibujar()
    self.raqueta:dibujar()
    self.pelota:dibujar()
    
    love.graphics.setFont(gFuentes['normal'])
    love.graphics.setColor(1, 1, 1)
    love.graphics.printf("Presiona ESPACIO para sacar", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    
    -- Dibujar HUD usando la función global pulida
    gDibujarHUD(self.vidas, self.puntuacion, self.nivel, self.mapaNivel:obtenerAvance())
end

return EstadoSaque
