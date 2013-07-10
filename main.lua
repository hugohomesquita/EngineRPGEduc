-- import
flower = require "hanappe/flower"
themes = require "hanappe/extensions/themes"
tiled = require "hanappe/extensions/tiled"
widget = require "hanappe/extensions/widget"
physics = require "hanappe/extensions/physics"
rpgmap = require "hanappe/RPGMap"
Resources = flower.Resources
require "hanappe/extensions/savefile-manager"

-- Resources setting
Resources.addResourceDirectory("assets")
Resources.addResourceDirectory("assets/fonts")
--Resources.addResourceDirectory("maps") debug


--[[
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX, 1, 1, 1, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_LAYOUT, 1, 0, 0, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_BASELINES, 1, 1, 0, 0, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_MODEL_BOUNDS, 2, 1, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_WORLD_BOUNDS, 2, 0.75, 0.75, 0.75 )
]]


GAME_FILE = savefiles.get "user"
--[[USER_DATA = {
  nome = "",
  xp = 0  
}
GAME_FILE.data = USER_DATA
GAME_FILE:saveGame()]]

-- Screen setting
local screenWidth = MOAIEnvironment.horizontalResolution or 800
local screenHeight = MOAIEnvironment.verticalResolution or 600
local screenDpi = MOAIEnvironment.screenDpi or 120
local viewScale = math.floor(screenDpi / 240) + 1

MOAISim.setHistogramEnabled(true) -- debug
MOAISim.setStep(1 / 60)
MOAISim.clearLoopFlags()
MOAISim.setLoopFlags(MOAISim.SIM_LOOP_ALLOW_BOOST)
MOAISim.setLoopFlags(MOAISim.SIM_LOOP_LONG_DELAY)
MOAISim.setBoostThreshold(0)
-- open window

flower.openWindow("Flower extensions", screenWidth, screenHeight, 1.0)

-- open scene
flower.openScene("scenes/game_scene")