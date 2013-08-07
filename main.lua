
modules = require "modules"

rpgmap = require "hanappe/RPGMap"
Resources = flower.Resources

-- Resources setting
Resources.addResourceDirectory("assets")
Resources.addResourceDirectory("assets/fonts")

-- Screen setting
local screenWidth = MOAIEnvironment.horizontalResolution or 1280
local screenHeight = MOAIEnvironment.verticalResolution or 720
local screenDpi = MOAIEnvironment.screenDpi or 120
local viewScale = math.floor(screenDpi / 240) + 1

--SCREEN SETTINGS 
--4.7"
--local screenWidth = 1600
--local screenHeight = 900
--local screenDpi = 96
--local viewScale = 1.77

MOAISim.setHistogramEnabled(true) -- debug
MOAISim.setStep(1 / 60)
MOAISim.clearLoopFlags()
MOAISim.setLoopFlags(MOAISim.SIM_LOOP_ALLOW_BOOST)
MOAISim.setLoopFlags(MOAISim.SIM_LOOP_LONG_DELAY)
MOAISim.setBoostThreshold(0)


-- open window
flower.openWindow("Flower extensions", screenWidth, screenHeight, viewScale)

-- open scene
flower.openScene(scenes.INITIAL)
--flower.openScene('minigames/quiz')