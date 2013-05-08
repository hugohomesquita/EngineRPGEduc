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
local Avatar = require "hanappe/class/Avatar"

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
RPGMap = class(TileMap)
M.RPGMap = RPGMap

function RPGMap:init()
    TileMap.init(self)
    
    
    
    self.world = nil
    self.objectLayer = nil
    self.collisionLayer = nil
    self.avatar = nil
    
    self:initSystems()
    self:initEventListeners()    
    
end

function RPGMap:setWorldPhysics(world)
    self.world = world
end

function RPGMap:initSystems()
    self.systems = {
        UpdatingSystem(self),
        MovementSystem(self),
        --CameraSystem(self),
        --RenderSystem(self),
    }
end

function RPGMap:initEventListeners()
    self:addEventListener("loadedData", self.onLoadedData, self)
    self:addEventListener("savedData", self.onSavedData, self)
end

function RPGMap:isCollison(x, y)
    local gid = self.collisionLayer:getGid(x, y)
    return gid > 0
end

function RPGMap:onLoadedData(e)
    self.objectLayer = self:findMapLayerByName("Object")
    self.collisionLayer = self:findMapLayerByName("MapCollision")
    self.eventLayer = self:findMapLayerByName("Event")
    if self.collisionLayer then
        self.collisionLayer:setVisible(false)
        self:createPhysicsCollision()
    end
    if self.objectLayer then
       -- self:createAvatar()
    end
    
    if self.eventLayer then
      self:createPhysicsEvent()
    end  
    
   -- self:setInvisibleLayerByName("MapBackground")
    --self:setInvisibleLayerByName("MapObject")
end

--RETORNA O X,Y DO HOTSPOT
function RPGMap:getPositionHotSpot(index)
    for i, event in ipairs(self.eventLayer.children) do
        if event.type == 'teleport' then
            local hotspotIndex = event:getProperty('hotspot')             
            if hotspotIndex == tostring(index) then
                return event.tileX,event.tileY
            end
        end
    end
end

function RPGMap:setInvisibleLayerByName(layerName)
    local layer = self:findMapLayerByName(layerName)
    if layer then
      for i, object in ipairs(layer.children) do        
          object:setVisible(false)
      end
    end
end

function string:split(separator)
    local init = 1
    return function()
        if init == nil then return nil end
        local i, j = self:find(separator, init)
        local result
        if i ~= nil then
            local ax = i - 1
            result = self:sub(init, ax)
            init = j + 1
        else
            result = self:sub(init)
            init = nil
        end
        return result
    end
end

function RPGMap:createPhysicsEvent()
  for i, object in ipairs(self.eventLayer.children) do   
      object.physics = {} 
      local body = self.world:addBody(MOAIBox2DBody.KINEMATIC)        
      local posX,posY = object:getPos()
      local width, height = object:getSize()
      local xMin, yMin, xMax, yMax = -width / 2, -height / 2, width / 2, height / 2   
      
      object:setPos(xMin, yMin)
      object:setParent(body)   
      body:setTransform(posX,posY)  
      
      local size = {x=1,y=1}
      if object:getProperty("size") then
        local i = 0
        str = object:getProperty("size")        
        for linha in str:split(",") do
          if i == 0 then 
            size.x = linha
          else
            size.y = linha
          end
          i = i + 1
        end          
      end   
                  
      p2x = 32 * size.x
      p2y = p2x / 2 - 16
      
      p3x = 0
      p3y = size.y * 32 - 16                
      
      p4x = size.y * 32
      p4y = p4x / 2 - 16
      
      if size.x > size.y then
        p3x = (size.x * 64 / 2) - 32 
        p3y = 32 * size.x / 2
      end
      if size.x < size.y then
        p3x = -((size.y * 32) - 32)
        p3y = 32 * size.y / 2
      end
      
      poly = {
        0, -16, 
        p2x, p2y, 
        p3x, p3y, 
        -p4x, p4y, 
      }
      body:setFixedRotation(0)  
      body:resetMassData()
      
      object.physics.fixture = body:addPolygon (poly)
      object.physics.fixture:setSensor(true)
      
      --CALLBACK PARA CHAMADA DO EVENTO
      --object.physics.fixture:setCollisionHandler(onCollide, MOAIBox2DArbiter.ALL)
      
      object.physics.body = body
  end
end


function RPGMap:createPhysicsCollision()
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

function RPGMap:onSavedData(e)
    
end

function RPGMap:onUpdate(e)  
    
    for i, system in ipairs(self.systems) do
        system:onUpdate()
    end
    
end

function RPGMap:updateRenderOrdem()
    --BACKGROUND
    local bg = self:findMapLayerByName("MapBackground")
    bg:setPriority(1)   
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

function MovementSystem:moveStep(object)  
    
    --VERIFICA SE TEM CONTROLLER E SE ESTÁ SE MOVIMENTANDO 
    if not object.controller then      
        return
    end
    object.controller:moveStep()
end


return M