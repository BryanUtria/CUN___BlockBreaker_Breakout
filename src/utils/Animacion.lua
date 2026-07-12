local Animacion = {}
Animacion.activas = {}

-- Función para cambiar un valor suavemente en el tiempo (Tweening)
function Animacion.interpolar(objeto, propiedad, valorDestino, duracion)
    table.insert(Animacion.activas, {
        objeto = objeto,
        propiedad = propiedad,
        valorInicial = objeto[propiedad],
        valorDestino = valorDestino,
        duracion = duracion,
        tiempo = 0
    })
end

function Animacion.actualizar(dt)
    for i = #Animacion.activas, 1, -1 do
        local anim = Animacion.activas[i]
        anim.tiempo = anim.tiempo + dt
        
        local progreso = anim.tiempo / anim.duracion
        if progreso >= 1 then
            progreso = 1
            anim.objeto[anim.propiedad] = anim.valorDestino
            table.remove(Animacion.activas, i)
        else
            -- Interpolación lineal básica (Linear Tween)
            anim.objeto[anim.propiedad] = anim.valorInicial + (anim.valorDestino - anim.valorInicial) * progreso
        end
    end
end

return Animacion
