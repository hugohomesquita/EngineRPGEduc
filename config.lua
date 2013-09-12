-- import
local flower = require "hanappe/flower"
local aspect = require "hanappe/extensions/aspect"

-- module
local M = {}

--------------------------------------------------------------------------------
-- Flower
--------------------------------------------------------------------------------

local screenWidth = MOAIEnvironment.horizontalResolution or 1280
local screenHeight = MOAIEnvironment.verticalResolution or 720
local viewScale = math.floor(math.max(math.min(screenWidth / 1280, screenHeight / 720), 1))

-- Resources setting
flower.Resources.addResourceDirectory("assets")
flower.Resources.addResourceDirectory("assets/fonts")
-- Set the screen size
flower.DEFAULT_SCREEN_WIDTH = screenWidth
flower.DEFAULT_SCREEN_HEIGHT = screenHeight

-- Set the scale of the Viewport
flower.DEFAULT_VIEWPORT_SCALE = viewScale

-- High quality rendering of Label
-- When enabled, it may take a long time to display the label.
flower.Label.HIGH_QUALITY_ENABLED = true

-- Set the default font
flower.Font.DEFAULT_FONT = "VL-PGothic.ttf"

-- Set the default font charcodes
-- Optimized by setting the loadable string in advance.
flower.Font.DEFAULT_CHARCODES = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 .,:;!?()&/-"

-- Default font points
flower.Font.DEFAULT_POINTS = 24

-- Set the texture filter of default
--flower.Texture.DEFAULT_FILTER = MOAITexture.GL_LINEAR
flower.Texture.DEFAULT_FILTER = MOAITexture.GL_NEAREST

--------------------------------------------------------------------------------
-- MOAI SDK
--------------------------------------------------------------------------------

-- Setting the FPS
MOAISim.setStep(1 / 60)

-- Setting of the operation of the Loop.
MOAISim.clearLoopFlags()
MOAISim.setLoopFlags(MOAISim.SIM_LOOP_ALLOW_BOOST)
MOAISim.setLoopFlags(MOAISim.SIM_LOOP_LONG_DELAY)

-- Sets the boost threshold
MOAISim.setBoostThreshold(0)

--------------------------------------------------------------------------------
--  AUDIO INIT
--------------------------------------------------------------------------------
audio.init()

--------------------------------------------------------------------------------
-- Debugging
--------------------------------------------------------------------------------

-- Show bounds of MOAIProp
--[[
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX, 1, 1, 1, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_LAYOUT, 1, 0, 0, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_BASELINES, 1, 1, 0, 0, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_MODEL_BOUNDS, 2, 1, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_WORLD_BOUNDS, 2, 0.75, 0.75, 0.75 )
]]

-- 
MOAISim.setHistogramEnabled(true)

-- Performance measurement.
--[[local timer = MOAITimer.new()
timer:setMode(MOAITimer.LOOP)
timer:setSpan(5)
timer:setListener(MOAITimer.EVENT_TIMER_LOOP,
    function()
        print("-------------------------------------------")
        print("FPS:", MOAISim.getPerformance())
        print("Draw:", MOAIRenderMgr.getPerformanceDrawCount())
        MOAISim.reportHistogram()
        MOAISim.reportLeaks()
    end)
timer:start()]]

--[[
local traceInterpector = aspect.Interceptor(widget)

function traceInterpector:beginProcess(context, ...)
    local info = debug.getinfo(4)
    local msg = string.format("[Trace][%s:%s][%s] Args = ", info.short_src, info.currentline, context.name)
    print(msg, ...)
end
]]

return M
