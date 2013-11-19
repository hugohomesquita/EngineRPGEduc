----------------------------------------------------------------------------------------------------
-- Simple example RPGMap.
--
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "hanappe/flower"
local tiled = require "hanappe/extensions/tiled"
local MapEvent = require "hanappe/MapEvent"

local entities = require "libs/entities"
local repositry = entities.repositry

local class = flower.class
local table = flower.table
local Layer = flower.Layer
local InputMgr = flower.InputMgr
local Camera = flower.Camera
local TileMap = tiled.TileMap
local TileObject = tiled.TileObject
local ClassFactory = flower.ClassFactory
local Group = flower.Group

-- class

local RPGMap
local UpdatingSystem
local RenderSystem

local MapObject = require "hanappe/plataform/MapObject"
local MovementSystem = require "hanappe/plataform/MovementSystem" 
local CameraSystem = require "hanappe/plataform/CameraSystem"
local EffectSystem = require "hanappe/plataform/EffectSystem"

local ActorController = require "hanappe/plataform/ActorController" 
local PlayerController = require "hanappe/plataform/PlayerController" 

----------------------------------------------------------------------------------------------------
-- @type RPGMap
----------------------------------------------------------------------------------------------------
RPGMap = class(TileMap)
M.RPGMap = RPGMap

function RPGMap:init()
    TileMap.init(self)
    self.objectFactory = ClassFactory(MapObject)    
    -- INIT VARIABLES LAYERS    
    self.objectLayer = nil
    self.eventLayer = nil
    self.mapObjectLayer = nil    
    self.mapCollisionLayer = nil    
    self.mapBackgroundLayer = nil    
        
    self.worldFreeze = false   
    self.DEBUG = false
    
    self:initEventListeners()   
    self:initLayer()
    self:initPhysics()
    self:initSystems()    
    
end


function RPGMap:initLayer()
    self.camera = Camera()

    local layer = Layer()
    --layer:setPriority(1)
    layer:setSortMode(MOAILayer.SORT_PRIORITY_ASCENDING)
    layer:setTouchEnabled(true)
    layer:setCamera(self.camera)    
    self:setLayer(layer)
end

function RPGMap:initPhysics()
    local world = MOAIBox2DWorld.new ()
    world:setGravity(0, 0)
    world:setUnitsToMeters(1/30)
    world:setDebugDrawEnabled(true)
    world:start()    
    self:setWorldPhysics(world)
    self.layer:setBox2DWorld(world)
end

function RPGMap:setScene(scene)
    self.scene = scene
    self.layer:setScene(scene)    
end

function RPGMap:setWorldPhysics(world)
    self.world = world
end

function RPGMap:initSystems()
    self.systems = {        
        MovementSystem(self),        
        CameraSystem(self),        
    }
end

function RPGMap:initEventListeners()
    self:addEventListener("loadedData", self.onLoadedData, self)
    self:addEventListener("savedData", self.onSavedData, self)    
    self:addEventListener("touchDown", self.OnTouchDown, self)
    self:addEventListener("touchUp", self.OnTouchUp, self)
    self:addEventListener("touchMove", self.OnTouchMove, self)
    self:addEventListener("touchCancel", self.OnTouchUp, self)
end

function RPGMap:isCollision(x, y)
    local gid = self.mapCollisionLayer:getGid(x, y)
    return gid > 0
end


function RPGMap:onLoadedData(e)    
    self.mapActorLayer = assert(self:findMapLayerByName("Object"))
    self.mapEventLayer = assert(self:findMapLayerByName("Event"))
    self.mapObjectLayer = assert(self:findMapLayerByName("MapObject"))    
    self.mapCollisionLayer = assert(self:findMapLayerByName("MapCollision"))    
    self.mapBackgroundLayer = assert(self:findMapLayerByName("MapBackground")) 
    
    self.player = self.mapActorLayer:findObjectByName("Player")

    if self.mapCollisionLayer then        
        self:createPhysicsCollision()
        self.mapCollisionLayer:setVisible(false)
    end    
    
    if self.mapEventLayer then
      self:createPhysicsEvent()
    end  
    
    self.mapBackgroundLayer:setPriority(1)  
    
    for i, system in ipairs(self.systems) do      
        system:onUpdate()        
    end 
    
    local effect = EffectSystem(self)
    effect:initEffect()
    
    -- INICIALIZANDO O AUDIO
    -- CARREGA OS DADOS DEFINIDOS COMO PROPRIEDADE DO TILEMAP
    if self:getProperty("sound") ~= nil then                      
        sound = {}
        sound.file = self:getProperty("sound")
        sound.looping = self:getProperty("sound_loop") and true or false
        sound.volume = tonumber(self:getProperty("sound_volume")) or 1        
        --self:dispatchEvent(MapEvent.SOUND, sound)  
    end
    --self:setInvisibleLayerByName("MapBackground")
    --self:setInvisibleLayerByName("MapObject")
end

function RPGMap:onSavedData(e)  
end

--RETORNA O X,Y DO HOTSPOT
function RPGMap:getPositionHotSpot(index)
    for i, event in ipairs(self.mapEventLayer.children) do
        if event.type == 'teleport' or event.type == 'initPosition' then
            local hotspotIndex = event:getProperty('hotSpot')                                     
            if hotspotIndex == tostring(index) then                
                return event.physics.body:getPosition()
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

function RPGMap:onUpdate(e)          
    for i, system in ipairs(self.systems) do      
        system:onUpdate()        
    end        
end

function RPGMap:stopWorld()
    self.world:stop()
    self.worldFreeze = true    
end

function RPGMap:startWorld()    
    self.world:start()    
    self.worldFreeze = false
end

function RPGMap:updateRenderOrdem()
    --BACKGROUND
    local bg = self:findMapLayerByName("MapBackground")
    bg:setPriority(1)   
end

function RPGMap:createPhysicsCollision()
    if self:isOrthogonal() then
        for y = 0, self.mapHeight - 1 do      
          for x = 0, self.mapWidth - 1 do
              local gid = self.mapCollisionLayer:getGid(x, y)
              if gid > 0 then
                  local body = self.world:addBody(MOAIBox2DBody.STATIC)                      
                  local xMin, yMin = x * 32, y * 32              
                  body:setTransform(xMin, yMin)  
                         
                  poly = {
                    0, 32,
                    0, 0,
                    32, 0,
                    32, 32,
                  }
                  body:addPolygon (poly)
                  body:setFixedRotation(0)  
                  body:resetMassData()          
              end
          end    
        end  
    elseif self:isIsometric() then
        for i, object in ipairs(self.mapCollisionLayer.children) do         
          for y = 0, self.mapHeight - 1 do
            for x = 0, self.mapWidth - 1 do        
              objeto = object.renderers[y * self.mapWidth + x + 1]
              if objeto then
                local body = self.world:addBody(MOAIBox2DBody.STATIC)        
                local posX,posY = objeto:getPos()
                local width, height = objeto:getSize()
                local xMin, yMin, xMax, yMax = -width / 2, -height / 2, width / 2, height / 2   
                
                objeto:setPos(xMin, yMin)
                objeto:setParent(body,"notAttr")   
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
end

function RPGMap:createPhysicsEvent()  
    if self:isOrthogonal() then
      for i, object in ipairs(self.mapEventLayer.children) do   
        object.physics = {} 
        local body = self.world:addBody(MOAIBox2DBody.KINEMATIC)        
        local posX,posY = object:getPos()
        local width, height = object:getSize()
        local xMin, yMin, xMax, yMax = -width / 2, -height / 2, width / 2, height / 2   
        
        object:setPos(xMin, yMin)              
        body:setTransform(posX,posY)                 

        poly = {
          0, height, 
          0, 0, 
          width, 0, 
          width, height, 
        }
        
        
        body:setFixedRotation(0)  
        body:resetMassData()
        
        object.physics.fixture = body:addPolygon (poly)
        object.physics.fixture:setSensor(true)        
        
        body.object = object
        object.physics.body = body
      end
      
    elseif self:isIsometric() then
      for i, object in ipairs(self.mapEventLayer.children) do   
        object.physics = {} 
        local body = self.world:addBody(MOAIBox2DBody.KINEMATIC)        
        local posX,posY = object:getPos()
        local width, height = object:getSize()
        local xMin, yMin, xMax, yMax = -width / 2, -height / 2, width / 2, height / 2   
        
        object:setPos(xMin, yMin)      
        object:setParent(body,"notAttr")   
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
        body.object = object
        object.physics.body = body
      end
    end
end


---
--  FUNÇÕES UTILIZADAS NO DEBUG
---

function RPGMap:debug()
    if self.DEBUG then
        self.DEBUG = false       
    else
        self.DEBUG = true        
    end
end

function RPGMap:OnTouchDown(e)
    if self.lastTouchEvent then
        return
    end
    self.lastTouchIdx = e.idx
    self.lastTouchX = e.x
    self.lastTouchY = e.y    
end

function RPGMap:OnTouchUp(e)
    if not self.lastTouchIdx then
        return
    end
    if self.lastTouchIdx ~= e.idx then
        return
    end
    self.lastTouchIdx = nil
    self.lastTouchX = nil
    self.lastTouchY = nil    
end

function RPGMap:OnTouchMove(e)
    if not self.lastTouchIdx then
        return
    end
    if self.lastTouchIdx ~= e.idx then
        return
    end
    
    local moveX = e.x - self.lastTouchX
    local moveY = e.y - self.lastTouchY
    local x, y, z = self.camera:getLoc()
    x = math.min(math.max(0, x - moveX), math.max(self:getWidth() - flower.viewWidth, 0))
    y = math.min(math.max(0, y - moveY), math.max(self:getHeight() - flower.viewHeight, 0))
    self.camera:setLoc(x, y, z)

    self.lastTouchX = e.x
    self.lastTouchY = e.y
end



return M