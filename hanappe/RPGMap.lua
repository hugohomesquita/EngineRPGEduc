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
    
    if self:isOrthogonal() then
          
    elseif self:isIsometric() then
        
    end
    
    if self.mapCollisionLayer then        
        self:createPhysicsCollision()
        --self.mapCollisionLayer:setVisible(false)
    end    
    
    if self.eventLayer then
      --self:createPhysicsEvent()
    end  
    
    self.mapBackgroundLayer:setPriority(1)  
    
    for i, system in ipairs(self.systems) do      
        system:onUpdate()        
    end 
    
    -- INICIALIZANDO O AUDIO
    -- CARREGA OS DADOS DEFINIDOS COMO PROPRIEDADE DO TILEMAP
    if self:getProperty("sound") ~= nil then                      
        sound = {}
        sound.file = self:getProperty("sound")
        sound.looping = self:getProperty("sound_loop") and true or false
        sound.volume = tonumber(self:getProperty("sound_volume")) or 1        
        --self:dispatchEvent(MapEvent.SOUND, sound)  
    end
    self:setInvisibleLayerByName("MapBackground")
    --self:setInvisibleLayerByName("MapObject")
end

function RPGMap:onSavedData(e)  
end

--RETORNA O X,Y DO HOTSPOT
function RPGMap:getPositionHotSpot(index)
    for i, event in ipairs(self.mapEventLayer.children) do
        if event.type == 'teleport' then
            local hotspotIndex = event:getProperty('hotSpot')                         
            if hotspotIndex == tostring(index) then                
                --return event.physics.body:getPosition()
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

return M