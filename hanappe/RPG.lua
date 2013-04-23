----------------------------------------------------------------------------------------------------
-- Simple example RPGMap.
--
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "hanappe/flower"
local tiled = require "hanappe/extensions/tiled"
local class = flower.class
local table = flower.table
local Layer = flower.Layer
local Camera = flower.Camera
local TileMap = tiled.TileMap
local TileObject = tiled.TileObject
local ClassFactory = flower.ClassFactory
local Group = flower.Group
-- class
local RPGMap
local RPGObject
local UpdatingSystem
local MovementSystem
local CameraSystem
local RenderSystem
local ActorController
local PlayerController

----------------------------------------------------------------------------------------------------
-- @type RPGMap
----------------------------------------------------------------------------------------------------
RPG = class(TileMap)
M.RPG = RPG

function RPG:init()
    TileMap.init(self)
    
    
    
    self.world = nil
    --self.objectFactory = ClassFactory(RPGObject)    
    --self:initLayer()
    self:initSystems()
    self:initEventListeners()    
    
end

function RPG:setWorldPhysics(world)
    self.world = world
end

function RPG:initLayer()
    local layer = Layer()
    local camera = Camera()
    layer:setCamera(camera)
    self:setLayer(layer)
    
end

function RPG:initSystems()
    self.systems = {
        UpdatingSystem(self),
        MovementSystem(self),
        --CameraSystem(self),
        --RenderSystem(self),
    }
end

function RPG:initEventListeners()
    self:addEventListener("loadedData", self.onLoadedData, self)
    self:addEventListener("savedData", self.onSavedData, self)
end

function RPG:isCollison(x, y)
    local gid = self.collisionLayer:getGid(x, y)
    return gid > 0
end

function RPG:onLoadedData(e)
    self.objectLayer = self:findMapLayerByName("Object")
    self.collisionLayer = self:findMapLayerByName("Collision")
    if self.collisionLayer then
        self.collisionLayer:setVisible(false)
        self:createPhysicsCollision()
    end
end

function RPG:createPhysicsCollision()
  local backg = self:findMapLayerByName('background')
    for i, object in ipairs(backg.children) do     
      object:setVisible(false)
    end
  for i, object in ipairs(self.collisionLayer.children) do         
    for y = 0, self.mapHeight - 1 do
      for x = 0, self.mapWidth - 1 do
        objeto = object.renderers[y * self.mapWidth + x + 1]
        if objeto then
          local body = self.world:addBody(MOAIBox2DBody.STATIC)        
          local posX,posY = objeto:getPos()
          local width, height = objeto:getSize()
          local xMin, yMin, xMax, yMax = -width / 2, -height / 2, width / 2, height / 2   
          
          objeto:setPos(xMin, yMin)
          objeto:setParent(body)   
          body:setTransform(posX+32,posY+16)  
                 
          poly = {
            0, -16,
            32, 0,
            0, 16,
            -32, 0,
          }
          body:addPolygon (poly)
          body:setFixedRotation(0)  
          body:resetMassData()  
        end
      end
    end      
  end
end

function RPG:onSavedData(e)
    
end

function RPG:onUpdate(e)  
    
    for i, system in ipairs(self.systems) do
        system:onUpdate()
    end
    self:updateRenderOrdem()
end

function RPG:updateRenderOrdem()
   --for i, object in ipairs(self.objectLayer:getObjects()) do
        --if object.name == "HugoHenrique" then
         -- self:updateRenderOrder(1)
          ---object:setPriority(object:vertexZ())
         -- print('fdfd')
      --  end    
        
   -- end
end

----------------------------------------------------------------------------------------------------
-- @type UpdatingSystem
----------------------------------------------------------------------------------------------------
UpdatingSystem = class()

function UpdatingSystem:init(tileMap)
    self.tileMap = tileMap
end

function UpdatingSystem:onUpdate() 
    local objectLayer = self.tileMap:findMapLayerByName('Object')
    --local objectLayer = self.tileMap.objects
    for i, object in ipairs(objectLayer:getObjects()) do
        if object.controller then
            object:onUpdate()
        end
    end
end


----------------------------------------------------------------------------------------------------
-- @type MovementSystem
----------------------------------------------------------------------------------------------------
MovementSystem = class()

function MovementSystem:init(tileMap)
    self.tileMap = tileMap
    self.objectLayer = nil   
end

function MovementSystem:onUpdate()
    local objectLayer = self.tileMap:findMapLayerByName('Object')
    for i, object in ipairs(objectLayer:getObjects()) do
        self:moveStep(object)        
    end
end
--moveStep
function MovementSystem:moveStep(object)  
    
    --VERIFICA SE TEM CONTROLLER E SE ESTÁ SE MOVIMENTANDO 
    if not object.controller or object.STATS == object.STATES.IDLE then      
        return
    end
    
    object:addLoc(object.currentMoveX, object.currentMoveY)
end

function MovementSystem:collisionWith(object, mapX, mapY)
end
function MovementSystem:collisionWithObjects(object, x, y)
end



function MovementSystem:collisionWithObjects(object, mapX, mapY)
    for i, object in ipairs(self.objectLayer:getObjects()) do
       if target ~= object and object:isCollisionByMapPosition(x, y, w, h) then
          return true
       end
    end
    return false
end

return M