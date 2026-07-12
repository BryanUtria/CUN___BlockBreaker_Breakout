local EstadoBase = require("src.states.EstadoBase")

local EstadoFinJuego = setmetatable({}, {__index = EstadoBase})
EstadoFinJuego.__index = EstadoFinJuego

function EstadoFinJuego.new()
    return setmetatable(EstadoBase.new(), EstadoFinJuego)
end

function EstadoFinJuego:entrar(params)
    self.puntuacion = params.puntuacion or 0
end

function EstadoFinJuego:actualizar(dt)
    if love.keyboard.fuePresionada("return") then
        gMaquinaEstados:cambiar("titulo")
    end
end

function EstadoFinJuego:dibujar()
    -- Dibujar el fondo global
    gDibujarFondoJuego()
    
    love.graphics.setColor(1, 0.2, 0.2)
    love.graphics.setFont(gFuentes['titulo'])
    love.graphics.printf("FIN DEL JUEGO", 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(gFuentes['normal'])
    love.graphics.printf("Puntuación Final: " .. tostring(self.puntuacion), 0, love.graphics.getHeight() / 2, love.graphics.getWidth(), "center")
    love.graphics.setFont(gFuentes['peque'])
    love.graphics.printf("Presiona ENTER para volver al menú", 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")
end

return EstadoFinJuego
