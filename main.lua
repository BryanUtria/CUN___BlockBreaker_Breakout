local CampoJuego = require("CampoJuego")

-- Instancia principal del juego
local juego

-- Controla la pantalla actual del juego ("menu" o "jugando")
local estado = "menu"

-- Variables para almacenar las diferentes fuentes y tamaños
local fuenteTitulo
local fuenteNormal
local fuentePeque

-- Tabla que define las propiedades y posición del botón "Empezar a Jugar"
local botonJugar = {
    x = 275,
    y = 350,
    ancho = 250,
    alto = 50,
    texto = "Empezar a Jugar",
    colorFondo = {0.2, 0.6, 0.8},
    colorHover = {0.3, 0.7, 0.9},
    colorTexto = {1, 1, 1}
}

function love.load()
    juego = CampoJuego.new(love.graphics.getWidth(), love.graphics.getHeight())
    
    fuenteTitulo = love.graphics.newFont(60)
    fuenteNormal = love.graphics.newFont(24)
    fuentePeque = love.graphics.newFont(16)
end

function love.update(dt)
    if estado == "jugando" then
        if juego and juego.enEjecucion then

        end
    end
end

function love.draw()
    if estado == "menu" then
        -- título principal
        love.graphics.setFont(fuenteTitulo)
        love.graphics.setColor(1, 0.8, 0.2)
        love.graphics.printf("Block Breaker", 0, 150, love.graphics.getWidth(), "center")
        
        -- Lógica para saber si el ratón (mouse) está sobre el botón
        local mx, my = love.mouse.getPosition()
        local hover = mx >= botonJugar.x and mx <= botonJugar.x + botonJugar.ancho and
                      my >= botonJugar.y and my <= botonJugar.y + botonJugar.alto

        if hover then
            love.graphics.setColor(botonJugar.colorHover)
        else
            love.graphics.setColor(botonJugar.colorFondo)
        end

        -- Rectángulo relleno con bordes redondeados (radio 10)
        love.graphics.rectangle("fill", botonJugar.x, botonJugar.y, botonJugar.ancho, botonJugar.alto, 10, 10)
        
        -- Texto centrado dentro del botón
        love.graphics.setFont(fuenteNormal)
        love.graphics.setColor(botonJugar.colorTexto)
        love.graphics.printf(botonJugar.texto, botonJugar.x, botonJugar.y + 10, botonJugar.ancho, "center")
        
        -- Créditos en la parte inferior
        love.graphics.setFont(fuentePeque)
        love.graphics.setColor(0.7, 0.7, 0.7)
        local creditos = "Desarrollado por:\nLaura Barbosa Bedoya\nAndrés Felipe Uribe Rodríguez\nBrayan Steven Castelblanco Utria"
        love.graphics.printf(creditos, 0, love.graphics.getHeight() - 90, love.graphics.getWidth(), "center")
        
        -- Restaurar el color a blanco puro (para no afectar otros dibujos)
        love.graphics.setColor(1, 1, 1)

    elseif estado == "jugando" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.setFont(fuenteNormal)
    end
end

local function iniciarPartida()
    estado = "jugando"
    juego:iniciar()
end

function love.mousepressed(x, y, button, istouch, presses)
    if estado == "menu" and button == 1 then
        if x >= botonJugar.x and x <= botonJugar.x + botonJugar.ancho and
           y >= botonJugar.y and y <= botonJugar.y + botonJugar.alto then
            iniciarPartida()
        end
    end
end

function love.keypressed(key)
    if estado == "menu" and key == "return" then
        iniciarPartida()
    end
end
