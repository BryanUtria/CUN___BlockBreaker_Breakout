local Particulas = {}

function Particulas.iniciar()
    Particulas.sistemas = {}
    
    -- Crear una imagen blanca de 3x3 píxeles en memoria para no depender de archivos externos
    local canvas = love.graphics.newCanvas(3, 3)
    love.graphics.setCanvas(canvas)
    love.graphics.clear(1, 1, 1, 1)
    love.graphics.setCanvas()
    Particulas.imagenBase = canvas
end

function Particulas.crearExplosion(x, y, color)
    local ps = love.graphics.newParticleSystem(Particulas.imagenBase, 50)
    -- Viven entre 0.2 y 0.5 segundos
    ps:setParticleLifetime(0.2, 0.5)
    -- Explotan en todas direcciones
    ps:setLinearAcceleration(-300, -300, 300, 300)
    
    if color then
        -- Van de opaco a transparente
        ps:setColors(color[1], color[2], color[3], 1, color[1], color[2], color[3], 0)
    else
        ps:setColors(1, 1, 1, 1, 1, 1, 1, 0)
    end
    
    ps:setSizes(1, 1.5, 0)
    -- Disparar 30 partículas de golpe
    ps:emit(30)
    
    table.insert(Particulas.sistemas, {
        sistema = ps,
        x = x,
        y = y
    })
end

function Particulas.actualizar(dt)
    for i = #Particulas.sistemas, 1, -1 do
        local ps = Particulas.sistemas[i]
        ps.sistema:update(dt)
        if ps.sistema:getCount() == 0 then
            table.remove(Particulas.sistemas, i)
        end
    end
end

function Particulas.dibujar()
    for _, ps in ipairs(Particulas.sistemas) do
        love.graphics.draw(ps.sistema, ps.x, ps.y)
    end
end

return Particulas
