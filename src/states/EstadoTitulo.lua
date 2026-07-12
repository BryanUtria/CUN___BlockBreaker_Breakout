local EstadoBase = require("src.states.EstadoBase")

local EstadoTitulo = setmetatable({}, {__index = EstadoBase})
EstadoTitulo.__index = EstadoTitulo

function EstadoTitulo.new()
    local self = setmetatable(EstadoBase.new(), EstadoTitulo)
    
    -- Shader de fondo con bloques cayendo
    local shaderCode = [[
        extern number iTime;
        extern vec2 iResolution;

        // Función para dibujar una capa de bloques con efecto parallax y extrusión 3D
        vec4 drawLayer(vec2 p, float scale, float speed, float seedOffset, float time) {
            vec2 gridPos = p * scale;
            gridPos.y += time * speed;
            
            vec2 cell = floor(gridPos);
            vec2 frac = fract(gridPos);
            
            // Semilla aleatoria
            float n = fract(sin(dot(cell, vec2(12.9898 + seedOffset, 78.233))) * 43758.5453);
            
            if (n > 0.7) {
                // Distancia para la cara frontal (superior)
                vec2 d = abs(frac - 0.5);
                float dist = max(d.x, d.y);
                
                // Distancia para la extrusión 3D (cara lateral/inferior) desplazada
                vec2 sideFrac = fract(gridPos - vec2(0.06, 0.06));
                float sideDist = max(abs(sideFrac.x - 0.5), abs(sideFrac.y - 0.5));
                
                // Distancia para la sombra en el suelo
                vec2 shadowFrac = fract(gridPos - vec2(0.2, 0.2));
                float shadowDist = max(abs(shadowFrac.x - 0.5), abs(shadowFrac.y - 0.5));
                
                float fade = sin(time * 2.0 + n * 20.0) * 0.3 + 0.7;
                
                // 1. Dibujar Cara Frontal
                if (dist < 0.35) {
                    vec3 bColor = vec3(1.0);
                    if (n < 0.76) bColor = vec3(1.0, 0.2, 0.3); // Rojo
                    else if (n < 0.82) bColor = vec3(0.2, 0.9, 0.2); // Verde
                    else if (n < 0.88) bColor = vec3(0.2, 0.7, 1.0); // Azul
                    else if (n < 0.94) bColor = vec3(1.0, 0.6, 0.1); // Naranja
                    else bColor = vec3(1.0, 0.9, 0.1); // Amarillo
                    
                    // Brillo en los bordes para simular bisel
                    float light = 1.0;
                    if (frac.x < 0.2 || frac.y < 0.2) light = 0.5; // Borde oscuro
                    if (frac.x > 0.8 || frac.y > 0.8) light = 1.2; // Borde iluminado
                    
                    return vec4(bColor * light * fade, 1.0);
                } 
                // 2. Dibujar Extrusión 3D (Profundidad)
                else if (sideDist < 0.35 || (dist > 0.35 && min(sideFrac.x, sideFrac.y) > 0.15 && max(sideFrac.x, sideFrac.y) < 0.85)) {
                    // Usamos colores mucho más oscuros para el lateral 3D
                    vec3 sideColor = vec3(1.0);
                    if (n < 0.76) sideColor = vec3(0.4, 0.05, 0.1); // Rojo oscuro
                    else if (n < 0.82) sideColor = vec3(0.05, 0.35, 0.05); // Verde oscuro
                    else if (n < 0.88) sideColor = vec3(0.05, 0.25, 0.4); // Azul oscuro
                    else if (n < 0.94) sideColor = vec3(0.4, 0.2, 0.02); // Naranja oscuro
                    else sideColor = vec3(0.4, 0.35, 0.02); // Amarillo oscuro
                    
                    return vec4(sideColor * fade, 1.0);
                }
                // 3. Dibujar Sombra
                else if (shadowDist < 0.35) {
                    return vec4(0.0, 0.0, 0.0, 0.5); // Sombra semitransparente
                }
            }
            return vec4(0.0);
        }

        vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
        {
            vec2 uv = screen_coords.xy / iResolution.xy;
            vec2 p = uv * 2.0 - 1.0;
            p.x *= iResolution.x / iResolution.y;
            
            // Fondo oscuro base
            vec3 bg = mix(vec3(0.02, 0.02, 0.08), vec3(0.15, 0.0, 0.25), uv.y);
            vec3 col = bg;
            
            // Renderizar 3 capas con diferentes escalas y velocidades (Parallax 3D)
            // Capa 3: Fondo lejano (pequeños y muy lentos)
            vec4 layer3 = drawLayer(p, 12.0, 0.2, 1.0, iTime);
            col = mix(col, layer3.rgb, layer3.a * 0.4); // Más oscuros por la niebla de distancia
            
            // Capa 2: Distancia media
            vec4 layer2 = drawLayer(p, 7.0, 0.4, 2.0, iTime);
            col = mix(col, layer2.rgb, layer2.a * 0.7);
            
            // Capa 1: Primer plano (grandes y muy lentos)
            vec4 layer1 = drawLayer(p, 3.5, 0.7, 3.0, iTime);
            col = mix(col, layer1.rgb, layer1.a);
            
            return vec4(col, 1.0);
        }
    ]]
    
    local exito, shader = pcall(love.graphics.newShader, shaderCode)
    if exito then
        self.fondoShader = shader
    end
    
    return self
end

function EstadoTitulo:actualizar(dt)
    if love.keyboard.fuePresionada("return") then
        gMaquinaEstados:cambiar("saque", {
            vidas = 3,
            puntuacion = 0,
            nivel = 1
        })
    end
end

function EstadoTitulo:dibujar()
    -- 1. Dibujar el fondo del menú (Shader animado)
    if self.fondoShader then
        love.graphics.setShader(self.fondoShader)
        self.fondoShader:send("iTime", love.timer.getTime())
        self.fondoShader:send("iResolution", {love.graphics.getWidth(), love.graphics.getHeight()})
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
        
        -- Capa semitransparente oscura para asegurar que el texto sea legible
        love.graphics.setColor(0, 0, 0, 0.3)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    else
        love.graphics.clear(0.05, 0.05, 0.1, 1)
    end
    
    -- 2. Dibujar el texto del título
    -- Sombra del título
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.setFont(gFuentes['titulo'])
    love.graphics.printf("BLOCK BREAKER", 4, love.graphics.getHeight() / 3 + 4, love.graphics.getWidth(), "center")
    
    -- Texto del título principal
    love.graphics.setColor(1, 0.8, 0.2)
    love.graphics.printf("BLOCK BREAKER", 0, love.graphics.getHeight() / 3, love.graphics.getWidth(), "center")
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(gFuentes['normal'])
    love.graphics.printf("Presiona ENTER para empezar", 0, love.graphics.getHeight() / 2 + 50, love.graphics.getWidth(), "center")
end

return EstadoTitulo
