local EstadoBase = require("src.states.EstadoBase")
local Mejora = require("src.entities.Mejora")
local Colisiones = require("src.core.Colisiones")

local EstadoJugar = setmetatable({}, {__index = EstadoBase})
EstadoJugar.__index = EstadoJugar

function EstadoJugar.new()
    return setmetatable(EstadoBase.new(), EstadoJugar)
end

function EstadoJugar:entrar(params)
    self.raqueta = params.raqueta
    self.mapaNivel = params.mapaNivel
    self.vidas = params.vidas
    self.puntuacion = params.puntuacion
    self.nivel = params.nivel
    
    self.pelotas = { params.pelota } -- Ahora soportamos múltiples pelotas
    self.mejoras = {}
    self.vidaExtraSoltada = false -- Bandera para soltar máximo 1 vida por nivel
    
    -- El shader ahora se inicializa globalmente en main.lua y se dibuja con gDibujarFondoJuego()
end

function EstadoJugar:actualizar(dt)
    if love.keyboard.fuePresionada("escape") then
        gMaquinaEstados:cambiar("pausa", {
            estadoJugar = self
        })
        return
    end

    self.raqueta:actualizar(dt)
    
    -- Actualizar Ladrillos (para efecto de brillo)
    for _, ladrillo in ipairs(self.mapaNivel.ladrillos) do
        if ladrillo.actualizar then
            ladrillo:actualizar(dt)
        end
    end

    -- Actualizar mejoras (Power-Ups)
    for i = #self.mejoras, 1, -1 do
        local m = self.mejoras[i]
        m:actualizar(dt)
        if m:colisiona(self.raqueta) then
            if m.efecto then m.efecto(self) end -- Ejecuta el truco elegante
            if gSonidos["mejora"] then
                gSonidos["mejora"]:stop()
                gSonidos["mejora"]:play()
            end
            table.remove(self.mejoras, i)
        elseif not m._activa then
            table.remove(self.mejoras, i)
        end
    end

    -- Actualizar todas las pelotas
    for k = #self.pelotas, 1, -1 do
        local pelota = self.pelotas[k]
        pelota:actualizar(dt)

        -- Colisión Pelota-Raqueta
        if pelota:colisiona(self.raqueta) then
            pelota._y = self.raqueta._y - pelota._alto
            pelota:rebotarEjeY()
            
            -- Encender el núcleo de neón de la raqueta
            self.raqueta._brillo = 1
            
            local centroRaqueta = self.raqueta._x + (self.raqueta._ancho / 2)
            local centroPelota = pelota._x + (pelota._ancho / 2)
            local t = (centroPelota - centroRaqueta) / (self.raqueta._ancho / 2)
            
            local maxVx = 400
            -- Conservamos un poco del impulso que traía (40%) y aplicamos la fuerza de la raqueta (80%)
            -- Esto evita giros de 180 grados instantáneos y hace que la física se sienta más natural
            pelota._dx = (pelota._dx * 0.4) + (t * maxVx * 0.8)
            
            if gSonidos["rebote"] then
                gSonidos["rebote"]:stop()
                gSonidos["rebote"]:play()
            end
        end

        -- Colisiones bordes de pantalla
        if pelota._x <= 0 then
            pelota._x = 0; pelota:rebotarEjeX()
        elseif pelota._x >= love.graphics.getWidth() - pelota._ancho then
            pelota._x = love.graphics.getWidth() - pelota._ancho; pelota:rebotarEjeX()
        end
        if pelota._y <= 0 then
            pelota._y = 0; pelota:rebotarEjeY()
        end

        -- Colisión Pelota-Ladrillos
        for i = #self.mapaNivel.ladrillos, 1, -1 do
            local ladrillo = self.mapaNivel.ladrillos[i]
            
            if ladrillo._enJuego and Colisiones.AABB(pelota, ladrillo) then
                Colisiones.resolverPelotaLadrillo(pelota, ladrillo)
                
                local destruido = ladrillo:alGolpear()
                if destruido then
                    self.puntuacion = self.puntuacion + ladrillo._puntos
                    gPuntosShake = 5
                    
                    if gSonidos["romper"] then
                        gSonidos["romper"]:stop()
                        gSonidos["romper"]:play()
                    end
                    
                    -- Crear partículas en el centro del ladrillo
                    gParticulas.crearExplosion(ladrillo._x + ladrillo._ancho/2, ladrillo._y + ladrillo._alto/2, ladrillo._color)
                    
                    -- Probabilidad de PowerUp (15%)
                    if math.random(1, 100) <= 15 then
                        local rnd = math.random(1, 3)
                        
                        -- Si salió vida extra, pero ya se soltó una en este nivel, cambiar a otro poder
                        if rnd == 1 and self.vidaExtraSoltada then
                            rnd = math.random(2, 3)
                        end
                        
                        local efecto, color, tipoNombre
                        
                        if rnd == 1 then
                            -- Vida Extra (Rojo)
                            self.vidaExtraSoltada = true
                            color = {1, 0.4, 0.4}
                            tipoNombre = "+1 Vida"
                            efecto = function(estado) estado.vidas = estado.vidas + 1 end
                        elseif rnd == 2 then
                            -- Paleta Ancha (Azul)
                            color = {0.4, 0.4, 1}
                            tipoNombre = "+ Raqueta"
                            efecto = function(estado)
                                -- Usamos Tweening para agrandar la raqueta suavemente
                                gAnimacion.interpolar(estado.raqueta, "_ancho", estado.raqueta._ancho + 30, 0.3)
                            end
                        elseif rnd == 3 then
                            -- Multibola (Verde)
                            color = {0.4, 1, 0.4}
                            tipoNombre = "+ Bolas"
                            efecto = function(estado)
                                local Pelota = require("src.entities.Pelota")
                                local nuevasPelotas = {}
                                -- Por cada pelota existente, clonarla dos veces
                                for _, pBase in ipairs(estado.pelotas) do
                                    for num = 1, 2 do
                                        local pNueva = Pelota.new(pBase._x, pBase._y, pBase._ancho, pBase._alto)
                                        pNueva._dx = math.random(-150, 150)
                                        -- Asegurar rebote hacia arriba o continuar la dirección pero variando la velocidad
                                        pNueva._dy = -math.abs(pBase._dy)
                                        table.insert(nuevasPelotas, pNueva)
                                    end
                                end
                                -- Insertar las nuevas pelotas en la tabla principal
                                for _, pNueva in ipairs(nuevasPelotas) do
                                    table.insert(estado.pelotas, pNueva)
                                end
                            end
                        end
                        table.insert(self.mejoras, Mejora.new(ladrillo._x + ladrillo._ancho/2, ladrillo._y, efecto, color, tipoNombre))
                    end
                end
                break -- Evitar múltiple choque en 1 frame
            end
        end

        -- Si la pelota cae por el fondo, eliminarla
        if pelota._y >= love.graphics.getHeight() then
            table.remove(self.pelotas, k)
        end
    end

    -- Perder vida si no quedan pelotas
    if #self.pelotas == 0 then
        self.vidas = self.vidas - 1
        gPuntosShake = 25
        self.raqueta._ancho = 64 -- Restaurar tamaño normal al morir
        
        if self.vidas <= 0 then
            -- Solo suena si es verdaderamente el fin del juego
            if gSonidos["perder"] then
                gSonidos["perder"]:stop()
                gSonidos["perder"]:play()
            end
            gMaquinaEstados:cambiar("fin_juego", {puntuacion = self.puntuacion})
        else
            -- Sonido de perder una sola vida
            if gSonidos["perderVida"] then
                gSonidos["perderVida"]:stop()
                gSonidos["perderVida"]:play()
            end
            
            gMaquinaEstados:cambiar("saque", {
                raqueta = self.raqueta,
                mapaNivel = self.mapaNivel,
                vidas = self.vidas,
                puntuacion = self.puntuacion,
                nivel = self.nivel
            })
        end
        return
    end

    -- Comprobar si se completó el nivel
    if self.mapaNivel:esNivelCompletado() then
        self.raqueta._ancho = 64 -- Restaurar al pasar nivel
        if self.nivel == 2 then
            gMaquinaEstados:cambiar("victoria", {puntuacion = self.puntuacion})
        else
            gMaquinaEstados:cambiar("saque", {
                vidas = self.vidas,
                puntuacion = self.puntuacion,
                nivel = self.nivel + 1
            })
        end
    end
end

function EstadoJugar:dibujar()
    -- Dibujar el fondo global (compartido con otros estados)
    gDibujarFondoJuego()

    self.mapaNivel:dibujar()
    self.raqueta:dibujar()
    
    for _, pelota in ipairs(self.pelotas) do
        pelota:dibujar()
    end

    for _, m in ipairs(self.mejoras) do
        m:dibujar()
    end
    
    -- Dibujar HUD usando la función global pulida
    gDibujarHUD(self.vidas, self.puntuacion, self.nivel, self.mapaNivel:obtenerAvance())
end

return EstadoJugar
