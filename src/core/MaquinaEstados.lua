local MaquinaEstados = {}
MaquinaEstados.__index = MaquinaEstados

function MaquinaEstados.new(estados)
    local self = setmetatable({}, MaquinaEstados)
    self.estados = estados or {}
    self.estadoActual = nil
    return self
end

function MaquinaEstados:cambiar(nombreEstado, params)
    assert(self.estados[nombreEstado], "El estado '" .. tostring(nombreEstado) .. "' no existe")
    if self.estadoActual then
        self.estadoActual:salir()
    end
    self.estadoActual = self.estados[nombreEstado]()
    self.estadoActual:entrar(params)
end

function MaquinaEstados:actualizar(dt)
    if self.estadoActual then
        self.estadoActual:actualizar(dt)
    end
end

function MaquinaEstados:dibujar()
    if self.estadoActual then
        self.estadoActual:dibujar()
    end
end

return MaquinaEstados
