-- import
flower = require "hanappe/flower"
tiled = require "hanappe/extensions/tiled"
widget = require "hanappe/extensions/widget"
Resources = flower.Resources

-- Resources setting
Resources.addResourceDirectory("assets")

-- debug
--[[
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX, 1, 1, 1, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_LAYOUT, 1, 0, 0, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.TEXT_BOX_BASELINES, 1, 1, 0, 0, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_MODEL_BOUNDS, 2, 1, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_WORLD_BOUNDS, 2, 0.75, 0.75, 0.75 )
]]

-- Screen setting
local screenWidth = MOAIEnvironment.horizontalResolution or 800
local screenHeight = MOAIEnvironment.verticalResolution or 600
local screenDpi = MOAIEnvironment.screenDpi or 120
local viewScale = math.floor(screenDpi / 240) + 1

-- open window
flower.openWindow("Flower extensions", screenWidth, screenHeight, viewScale)

-- open scene
--flower.openScene("main_scene")