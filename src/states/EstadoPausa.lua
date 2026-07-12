local EstadoBase = require("src.states.EstadoBase")

local EstadoPausa = setmetatable({}, {__index = EstadoBase})
EstadoPausa.__index = EstadoPausa

function EstadoPausa.new()
    return setmetatable(EstadoBase.new(), EstadoPausa)
end

function EstadoPausa:entrar(params)
    self.estadoJugar = params.estadoJugar
end

function EstadoPausa:actualizar(dt)
    if love.keyboard.fuePresionada("escape") or love.keyboard.fuePresionada("return") or love.keyboard.fuePresionada("space") then
        -- Volver al juego (could use a simple debounce in main.lua)
        gMaquinaEstados.estadoActual = self.estadoJugar
    end
end

function EstadoPausa:dibujar()
    -- Dibujar el estado de juego debajo
    self.estadoJugar:dibujar()
    
    love.graphics.setColor(0, 0, 0, 0.5)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(gFuentes['titulo'])
    love.graphics.printf("PAUSA", 0, love.graphics.getHeight() / 2 - 30, love.graphics.getWidth(), "center")
end

return EstadoPausa
