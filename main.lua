
modules = require "modules"

rpgmap = require "hanappe/RPGMap"
Resources = flower.Resources
require "hanappe/extensions/savefile-manager"



-- Resources setting
Resources.addResourceDirectory("assets")
Resources.addResourceDirectory("assets/fonts")

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
flower.openScene(scenes.INITIAL)