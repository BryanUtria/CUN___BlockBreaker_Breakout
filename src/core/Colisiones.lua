local Colisiones = {}

-- Función para verificar si dos rectángulos se solapan (AABB puro)
function Colisiones.AABB(a, b)
    if a._x > b._x + b._ancho or b._x > a._x + a._ancho then
        return false
    end
    if a._y > b._y + b._alto or b._y > a._y + a._alto then
        return false
    end
    return true
end

-- Función para resolver el choque contra un ladrillo calculando el eje de menor solape (Anti-Tunneling)
function Colisiones.resolverPelotaLadrillo(pelota, ladrillo)
    local overlapLeft = (pelota._x + pelota._ancho) - ladrillo._x
    local overlapRight = (ladrillo._x + ladrillo._ancho) - pelota._x
    local overlapTop = (pelota._y + pelota._alto) - ladrillo._y
    local overlapBottom = (ladrillo._y + ladrillo._alto) - pelota._y
    
    -- Encontrar el menor solapamiento
    local minOverlap = math.min(overlapLeft, overlapRight, overlapTop, overlapBottom)
    
    -- Solo rebotamos si la pelota se mueve HACIA la cara con la que chocó
    -- Esto soluciona los rebotes "locos" cuando choca en esquinas o entre dos ladrillos
    if minOverlap == overlapTop and pelota._dy > 0 then
        pelota:rebotarEjeY()
        pelota._y = ladrillo._y - pelota._alto
    elseif minOverlap == overlapBottom and pelota._dy < 0 then
        pelota:rebotarEjeY()
        pelota._y = ladrillo._y + ladrillo._alto
    elseif minOverlap == overlapLeft and pelota._dx > 0 then
        pelota:rebotarEjeX()
        pelota._x = ladrillo._x - pelota._ancho
    elseif minOverlap == overlapRight and pelota._dx < 0 then
        pelota:rebotarEjeX()
        pelota._x = ladrillo._x + ladrillo._ancho
    end
end

return Colisiones
