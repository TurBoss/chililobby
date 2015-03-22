ChiliFX = LCS.class{}

function ChiliFX:init()
    self.enabled = gl.CreateShader ~= nil

    Spring.Log("chililobby", LOG.NOTICE, "ChiliFX enabled: " .. tostring(self.enabled))
    Spring.Log("chililobby", LOG.NOTICE, "ChiliFX Loading shaders...")
    self:InitShaders()
    Spring.Log("chililobby", LOG.NOTICE, "ChiliFX Loaded shaders.")
end

function ChiliFX:InitShaders()
    self:InitFadeShader()
end

function ChiliFX:InitFadeShader()
    if self.enabled then
        local shader = gl.CreateShader({
            fragment = [[
                uniform sampler2D tex;
                uniform float multi;
                attribute vec4 gl_Color;
                void main() {
                    gl_FragColor = texture2D(tex, gl_TexCoord[0].st);
                    if (gl_FragColor.rgb == vec3(0.0,0.0,0.0) && gl_FragColor.a > 0.6) {
                        vec2 blurSize = vec2(0.002, 0.002);
                        gl_FragColor = gl_Color + (texture2D(tex, gl_TexCoord[0].st + blurSize) + texture2D(tex, gl_TexCoord[0].st + blurSize * 2) + texture2D(tex, gl_TexCoord[0].st - blurSize) + texture2D(tex, gl_TexCoord[0].st- blurSize*2))/10;
                    } else {
                        gl_FragColor *= gl_Color;
                    }
                    gl_FragColor *= multi;
                }
            ]],
        })
        local glslLog = gl.GetShaderLog()
        if glslLog ~= "" then 
            Spring.Log("chililobby", LOG.ERROR, glslLog) 
        else
            local texID = gl.GetUniformLocation(shader, "tex")
            local multiID = gl.GetUniformLocation(shader, "multi")
            
            self.fadeShader = {
                shader = shader,
                texID = texID,
                multiID = multiID,
            }
        end
    end
end

-- public functions
function ChiliFX:AddFadeEffect(effect)
    local obj = effect.obj
    local fadeTime = effect.fadeTime
    local callback = effect.callback
    local endValue = effect.endValue
    local startValue = effect.startValue or 1

    local shaderObj = self.fadeShader
    if not (self.enabled and shaderObj) then
        if callback then callback() end
        return
    end

    local start = os.clock()

    if obj._origDraw == nil then
        obj._origDraw = obj.DrawControl
    end

    obj.DrawControl = function(...)
        local progress = math.min((os.clock() - start) / fadeTime, 1)
        local value = startValue + progress * (endValue - startValue)

        gl.UseShader(shaderObj.shader)
        gl.Uniform(shaderObj.texID, 0)
        gl.Uniform(shaderObj.multiID, value)
        obj._origDraw(...) 
        gl.UseShader(0)
        obj:Invalidate()
        if progress == 1 then
            obj.DrawControl = obj._origDraw
            if callback then callback() end
        end
    end
    
    if not obj.children then return end
    for _, child in pairs(obj.children) do
        if type(child) == "table" then
            effect.obj = child
            effect.callback = nil
            self:AddFadeEffect(effect)
        end
    end
end

ChiliFX = ChiliFX()