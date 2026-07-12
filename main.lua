local MaquinaEstados = require("src.core.MaquinaEstados")
local EstadoTitulo = require("src.states.EstadoTitulo")
local EstadoSaque = require("src.states.EstadoSaque")
local EstadoJugar = require("src.states.EstadoJugar")
local EstadoPausa = require("src.states.EstadoPausa")
local EstadoFinJuego = require("src.states.EstadoFinJuego")
local EstadoVictoria = require("src.states.EstadoVictoria")

-- Módulos de pulido globales (Tweening y Partículas)
gAnimacion = require("src.utils.Animacion")
gParticulas = require("src.core.Particulas")

function love.load()
    -- Cargar fuentes globales
    gFuentes = {
        ['titulo'] = love.graphics.newFont(60),
        ['normal'] = love.graphics.newFont(24),
        ['peque'] = love.graphics.newFont(16)
    }
    
    -- Variables globales para pulido (Game Feel)
    gPuntosShake = 0
    gParticulas.iniciar()
    
    -- Las imágenes estáticas ya no son necesarias (usamos shaders)
    
    -- Cargar sonidos (usamos pcall por si no existen los archivos aún)
    gSonidos = {}
    local function cargarSonido(nombre, ruta)
        local exito, sonido = pcall(love.audio.newSource, ruta, "static")
        if exito then gSonidos[nombre] = sonido end
    end
    
    cargarSonido("rebote", "assets/sounds/rebote.mp3")
    cargarSonido("romper", "assets/sounds/romper.mp3")
    cargarSonido("mejora", "assets/sounds/mejora.mp3")
    cargarSonido("perder", "assets/sounds/perder.mp3")
    cargarSonido("perderVida", "assets/sounds/perderVida.mp3")
    
    -- Cargar música de fondo (usamos "stream" en lugar de "static" porque es un archivo largo y ahorra RAM)
    local exitoMusica, musica = pcall(love.audio.newSource, "assets/sounds/musica.ogg", "stream")
    if exitoMusica then
        gSonidos["musica"] = musica
        musica:setLooping(true) -- Que se repita infinitamente
        musica:setVolume(0.3)   -- Tono moderado (30% de volumen)
        musica:play()
    end
    
    -- Tabla para rastrear teclas presionadas una sola vez en el frame
    love.keyboard.keysPressed = {}
    
    -- Configurar semilla aleatoria
    math.randomseed(os.time())
    
    -- Inicializar máquina de estados
    gMaquinaEstados = MaquinaEstados.new({
        ['titulo'] = function() return EstadoTitulo.new() end,
        ['saque'] = function() return EstadoSaque.new() end,
        ['jugar'] = function() return EstadoJugar.new() end,
        ['pausa'] = function() return EstadoPausa.new() end,
        ['fin_juego'] = function() return EstadoFinJuego.new() end,
        ['victoria'] = function() return EstadoVictoria.new() end
    })
    
    -- Inicializar el shader de la partida de forma global
    local shaderCode = [[
        #define speed 2.0 

        extern number iTime;
        extern vec2 iResolution;
        
        float jTime;

        float amp(vec2 p){
            return smoothstep(1.,8.,abs(p.x));   
        }

        float hash21(vec2 co){
            return fract(sin(dot(co.xy,vec2(1.9898,7.233)))*45758.5433);
        }
        
        float hash(vec2 uv){
            float a = amp(uv);
            float w = a>0. ? (1.-.4 * pow(0.51+0.49*sin((.02*(uv.y+.5*uv.x)-jTime)*2.), 128.0)) : 0.;
            return (a>0.? a*sqrt(a)*hash21(uv)*w : 0.);
        }

        float edgeMin(float dx,vec2 da, vec2 db,vec2 uv){
            return min(min((1.-dx)*db.y, da.x), da.y);
        }

        vec2 trinoise(vec2 uv){
            const float sq = sqrt(1.5);
            uv.x *= sq;
            uv.y -= .5*uv.x;
            vec2 d = fract(uv);
            uv -= d;

            bool c = dot(d,vec2(1.0))>1.;

            vec2 dd = 1.-d;
            vec2 da = c?dd:d;
            vec2 db = c?d:dd;
            
            float nn = hash(uv+ (c ? 1.0 : 0.0));
            float n2 = hash(uv+vec2(1.0,0.0));
            float n3 = hash(uv+vec2(0.0,1.0));
            
            float nmid = mix(n2,n3,d.y);
            float ns = mix(nn,c?n2:n3,da.y);
            float dx = da.x/db.y;
            return vec2(mix(ns,nmid,dx), edgeMin(dx, da, db, uv+d));
        }

        vec2 map(vec3 p){
            // Para figuras "más de bloques", redondeamos las coordenadas XZ (Voxelización)
            vec2 grid = floor(p.xz * 1.5) / 1.5;
            vec2 n = trinoise(grid);
            return vec2(p.y - 1.5 * n.x, n.y);
        }

        vec3 grad(vec3 p){
            const vec2 e = vec2(.01,0);
            float a =map(p).x;
            return vec3(map(p+e.xyy).x-a
                        ,map(p+e.yxy).x-a
                        ,map(p+e.yyx).x-a)/e.x;
        }

        vec2 intersect(vec3 ro,vec3 rd){
            float d =0.,h=0.;
            for(int i = 0;i<80;i++){ 
                vec3 p = ro+d*rd;
                vec2 s = map(p);
                h = s.x;
                d+= h*.4; // Reducido para navegar sobre bloques planos sin atravesarlos
                if(abs(h)<.003*d)
                    return vec2(d,s.y);
                if(d>150.|| p.y>2.) break;
            }
            return vec2(-1.0);
        }

        void addsun(vec3 rd,vec3 ld,inout vec3 col){
            float sun = smoothstep(.21,.2,distance(rd,ld));
            if(sun>0.){
                float yd = (rd.y-ld.y);
                float a =sin(3.1*exp(-(yd)*14.)); 
                sun*=smoothstep(-.8,0.,a);
                col = mix(col,vec3(1.,.8,.4)*.75,sun);
            }
        }

        float starnoise(vec3 rd){
            float c = 0.;
            vec3 p = normalize(rd)*300.;
            for (float i=0.;i<4.;i++)
            {
                vec3 q = fract(p)-.5;
                vec3 id = floor(p);
                float c2 = smoothstep(.5,0.,length(q));
                c2 *= step(hash21(id.xz/id.y),.06-i*i*0.005);
                c += c2;
                p = p*.6+.5*p*mat3(0.6,0,0.8,0,1,0,-0.8,0,0.6);
            }
            c*=c;
            float g = dot(sin(rd*10.512),cos(rd.yzx*10.512));
            c*=smoothstep(-3.14,-.9,g)*.5+.5*smoothstep(-.3,1.,g);
            return c*c;
        }

        vec3 gsky(vec3 rd,vec3 ld,bool mask){
            float haze = exp2(-5.*(abs(rd.y)-.2*dot(rd,ld)));
            float st = mask?(starnoise(rd))*(1.-min(haze,1.)):0.;
            vec3 back = vec3(.4,.1,.7);
            vec3 col=clamp(mix(back,vec3(.7,.1,.4),haze)+st,0.,1.);
            if(mask)addsun(rd,ld,col);
            return col;  
        }

        vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
        {
            vec2 uv = (2.0*screen_coords.xy-iResolution.xy)/iResolution.y;
            uv.y = -uv.y; 
            
            float dt = fract(hash21(screen_coords.xy)+iTime)*0.25;
            jTime = mod(iTime-dt*0.016,4000.);
            
            vec3 ro = vec3(0.,1.5,(-20000.+jTime*speed));
            vec3 rd = normalize(vec3(uv, 1.2)); 
            
            vec2 i = intersect(ro,rd);
            float d = i.x;
            
            vec3 ld = normalize(vec3(0,.125+.05*sin(.1*jTime),1));

            vec3 fog = d>0.?exp2(-d*vec3(.14,.1,.28)):vec3(0.);
            vec3 sky = gsky(rd,ld,d<0.);
            
            vec3 p = ro+d*rd;
            vec3 n = normalize(grad(p));
            
            float diff = dot(n,ld)+.1*n.y;
            vec3 col = vec3(.1,.11,.18)*diff;
            
            vec3 rfd = reflect(rd,n); 
            vec3 rfcol = gsky(rfd,ld,true);
            
            col = mix(col,rfcol,.05+.95*pow(max(1.+dot(rd,n),0.),5.));
            
            // Vaporwave paleta
            col = mix(col,vec3(.4,.5,1.),smoothstep(.05,.0,i.y));
            col = mix(sky,col,fog);
            col = sqrt(col);
            
            if(d<0.) d=1e6;
            
            col *= 0.45; // Oscurecer el fondo para no interferir con el juego
            return vec4(clamp(col,0.,1.), 1.0);
        }
    ]]
    local exito, shader = pcall(love.graphics.newShader, shaderCode)
    if exito then gFondoJuegoShader = shader end
    
    gMaquinaEstados:cambiar("titulo")
end

-- Función auxiliar global para dibujar el fondo sin repetir código
function gDibujarFondoJuego()
    if gFondoJuegoShader then
        love.graphics.setShader(gFondoJuegoShader)
        gFondoJuegoShader:send("iTime", love.timer.getTime())
        gFondoJuegoShader:send("iResolution", {love.graphics.getWidth(), love.graphics.getHeight()})
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setShader()
    else
        love.graphics.clear(0.05, 0.05, 0.1, 1)
    end
end

-- Función auxiliar global para dibujar el HUD con un estilo más pulido
function gDibujarHUD(vidas, puntos, nivel, avance)
    local w = love.graphics.getWidth()
    
    -- Fondo de la barra superior transparente (sin rectángulo oscuro)
    -- Se elimina el fill de fondo
    
    -- Borde inferior de la barra (Línea suave y sutil con un poco de glow)
    love.graphics.setColor(0, 0.8, 1, 0.1)
    love.graphics.rectangle("fill", 0, 34, w, 3) -- Glow externo
    love.graphics.setColor(0, 0.8, 1, 0.4)
    love.graphics.rectangle("fill", 0, 35, w, 1) -- Línea central fina
    
    love.graphics.setFont(gFuentes['peque'])
    
    -- Vidas (Ícono de Corazón dibujado manualmente)
    love.graphics.setColor(1, 0.3, 0.3)
    local hx, hy = 25, 17
    love.graphics.circle("fill", hx-3, hy-3, 3)
    love.graphics.circle("fill", hx+3, hy-3, 3)
    love.graphics.polygon("fill", hx-6, hy-2.5, hx+6, hy-2.5, hx, hy+5)
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(tostring(vidas), 40, 9)
    
    -- Puntos (Ícono de Estrella dibujado manualmente)
    love.graphics.setColor(1, 0.8, 0.2)
    local sx, sy = 90, 17
    local starPts = { 
        sx, sy-6, sx+1.5, sy-1.5, sx+6, sy-1.5, sx+2.5, sy+1, 
        sx+4, sy+6, sx, sy+3.5, sx-4, sy+6, sx-2.5, sy+1, 
        sx-6, sy-1.5, sx-1.5, sy-1.5 
    }
    love.graphics.polygon("fill", starPts)
    
    love.graphics.print("PUNTOS:", 105, 9)
    love.graphics.setColor(1, 1, 1)
    -- Se aumenta el espaciado para que el número de puntos no quede pegado al texto
    love.graphics.print(tostring(puntos), 195, 9)
    
    -- Avance (Barra de progreso visual)
    local barW = 200
    local barH = 14
    local barX = (w - barW) / 2
    local barY = 10
    
    -- Fondo de la barra de avance
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", barX, barY, barW, barH, 4, 4)
    
    -- Relleno de progreso (Color que va de cyan a verde)
    local ratio = avance / 100
    love.graphics.setColor(0.2, 1.0 * ratio + 0.5, 1.0 * (1 - ratio) + 0.2, 0.9)
    love.graphics.rectangle("fill", barX, barY, barW * ratio, barH, 4, 4)
    
    -- Borde de la barra de avance
    love.graphics.setColor(1, 1, 1, 0.4)
    love.graphics.rectangle("line", barX, barY, barW, barH, 4, 4)
    
    -- Texto de porcentaje sobre la barra
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.printf(tostring(avance) .. "%", 0, 8, w, "center")
    
    -- Nivel (Texto Magenta/Morado)
    love.graphics.setColor(0.8, 0.2, 1)
    love.graphics.print("NIVEL:", w - 100, 9)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(tostring(nivel), w - 40, 9)
    
    -- Restaurar color
    love.graphics.setColor(1, 1, 1, 1)
end

function love.update(dt)
    -- Limitar dt para evitar saltos y tunneling en frames lentos
    if dt > 0.05 then dt = 0.05 end
    
    -- Actualizar el Screen Shake
    if gPuntosShake > 0 then
        gPuntosShake = gPuntosShake - dt * 60
        if gPuntosShake < 0 then gPuntosShake = 0 end
    end
    
    -- Actualizar el estado actual (entrada y lógica delegadas)
    gMaquinaEstados:actualizar(dt)
    
    -- Actualizar Sistemas de Pulido
    gAnimacion.actualizar(dt)
    gParticulas.actualizar(dt)
    
    -- Limpiar teclas después del update
    love.keyboard.keysPressed = {}
end

-- Función nativa de LÖVE para detectar cuando se presiona una tecla
function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

-- Función auxiliar para verificar si se presionó una tecla en este frame
function love.keyboard.fuePresionada(key)
    return love.keyboard.keysPressed[key]
end

function love.draw()
    love.graphics.push()
    
    -- Aplicar traslación para Screen Shake
    if gPuntosShake > 0 then
        local dx = math.random(-gPuntosShake, gPuntosShake)
        local dy = math.random(-gPuntosShake, gPuntosShake)
        love.graphics.translate(dx, dy)
    end
    
    -- Dibujar el estado actual
    gMaquinaEstados:dibujar()
    
    -- Dibujar partículas encima del juego (afectadas por el Screen Shake)
    gParticulas.dibujar()
    
    love.graphics.pop()
end
