----------------------------------------------------------------------------------------------------
-- @type CameraSystem
----------------------------------------------------------------------------------------------------

local flower = require "hanappe/flower"
local class = flower.class

local CameraSystem = class()

CameraSystem = class()

CameraSystem.MARGIN_HEIGHT = 140

function CameraSystem:init(tileMap)
    self.tileMap = assert(tileMap)
end

function CameraSystem:onLoadedData(e)
    self:onUpdate()
end

function CameraSystem:onUpdate()
    if self.tileMap.DEBUG == false then
      self:scrollCameraToFocusObject()
    end
end

function CameraSystem:scrollCameraToCenter(x, y)
    local cx, cy = flower.getViewSize()
    self:scrollCamera(x - (cx/2), y - (cy/2))    
end
function CameraSystem:scrollCamera(x, y)
    nx,ny = math.floor(x), math.floor(y)
    self.tileMap.camera:setLoc(nx,ny)
end

function CameraSystem:scrollCameraToFocusObject()
    local x,y = self.tileMap.player:getLoc()
    self:scrollCameraToCenter(x, y)
end

return CameraSystem