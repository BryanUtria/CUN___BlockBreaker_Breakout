local EstadoBase = require("src.states.EstadoBase")

local EstadoVictoria = setmetatable({}, {__index = EstadoBase})
EstadoVictoria.__index = EstadoVictoria

function EstadoVictoria.new()
    return setmetatable(EstadoBase.new(), EstadoVictoria)
end

function EstadoVictoria:entrar(params)
    self.puntuacion = params.puntuacion or 0
end

function EstadoVictoria:actualizar(dt)
    if love.keyboard.fuePresionada("return") then
        gMaquinaEstados:cambiar("titulo")
    end
end

function EstadoVictoria:dibujar()
    -- Dibujar el fondo global
    gDibujarFondoJuego()
    
    love.graphics.setColor(0.2, 1, 0.2)
    love.graphics.setFont(gFuentes['titulo'])
    love.graphics.printf("¡VICTORIA!", 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(gFuentes['normal'])
    love.graphics.printf("Has completado el juego.", 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    love.graphics.printf("Puntuación Final: " .. tostring(self.puntuacion), 0, love.graphics.getHeight() / 2 + 40, love.graphics.getWidth(), "center")
    
    love.graphics.setFont(gFuentes['peque'])
    love.graphics.printf("Presiona ENTER para volver al título", 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
end

return EstadoVictoria
