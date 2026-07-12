local EstadoBase = {}
EstadoBase.__index = EstadoBase

function EstadoBase.new()
    return setmetatable({}, EstadoBase)
end

function EstadoBase:entrar(params) end
function EstadoBase:salir() end
function EstadoBase:actualizar(dt) end
function EstadoBase:dibujar() end

return EstadoBase
