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
local MapObject
local RPGMap
local UpdatingSystem
local RenderSystem


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
    world:setDebugDrawEnabled(false)
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
        --RenderSystem(self),
    }
end

function RPGMap:initEventListeners()
    self:addEventListener("loadedData", self.onLoadedData, self)
    self:addEventListener("savedData", self.onSavedData, self)
end


function RPGMap:isCollision(x, y)
    local gid = self.collisionLayer:getGid(x, y)
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
    
    if self.collisionLayer then
        --self.collisionLayer:setVisible(false)
        --self:createPhysicsCollision()
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
    --self:setInvisibleLayerByName("MapBackground")
    --self:setInvisibleLayerByName("MapObject")
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

function RPGMap:onSavedData(e)
    
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

----------------------------------------------------------------------------------------------------
-- @type MapObject
----------------------------------------------------------------------------------------------------
MapObject = class(TileObject)
M.MapObject = MapObject


-- Events
MapObject.EVENT_WALK_START = "walkStart"
MapObject.EVENT_WALK_STOP = "walkStop"

-- Direction
MapObject.DIR_UP = "north"
MapObject.DIR_LEFT = "west"
MapObject.DIR_RIGHT = "east"
MapObject.DIR_DONW = "south"

-- Move speed
MapObject.MOVE_SPEED = 100

-- Direction to AnimationName
MapObject.DIR_TO_ANIM = {
    north = "walkNortheast",
    south = "walkSouthwest",
    east = "walkSoutheast",
    west = "walkNorthwest",
}

MapObject.DIR_TO_INDEX = {
    north = 10,
    south = 46,
    east = 28,
    west = 64,
}

MapObject.DIR_TO_VELOCITY = {
    north = {x = 1, y = -0.5},    
    west = {x = -1, y = -0.5},
    east = {x = 1, y = 0.5},
    south = {x = -1, y = 0.5},
}

function MapObject:init(tileMap)
    TileObject.init(self, tileMap)    
    self.isMapObject = true
    
    self.colliding = false
    self.collisionSide = nil
    self.walking = false        
    self.mapX = 0
    self.mapY = 0
    self.controller = nil 
    self.physics = {}        
end

function MapObject:loadData(data)
    TileObject.loadData(self, data)    
    self.mapX = math.floor(data.x / self.tileMap.tileWidth)
    self.mapY = math.floor(data.y / self.tileMap.tileHeight) - 1
    
    if self.type == "Actor" then
        self.controller = PlayerController(self)    
        if self.physics.fixture then
            self.physics.fixture:setCollisionHandler(function(phase, a, b, arbiter)
                                 self:onCollide(phase, a, b, arbiter)
                              end, MOAIBox2DArbiter.ALL)
        end
    elseif self.type == "Actor" then            
      --self.controller = ActorController(self)
    end
end

function MapObject:isWalking()
    return self.walking
end

function MapObject:isColliding()
    return self.colliding
end

function MapObject:onCollide(phase, fixtureA, fixtureB, arbiter)   
  local objectA = fixtureA:getBody()   
  local objectB = fixtureB:getBody() 
  local objects = {}  
  if phase == MOAIBox2DArbiter.BEGIN then       
      
    if objectB.object then      
      objects.objectB = objectB.object
      objects.objectA = objectA.object
      
      objectB.object.physics.body:setLinearVelocity(0, 0)
      objectB.object.physics.fixture:setFriction(0)
      objectB.object.physics.fixture:setRestitution(0)
      objectB.object.physics.fixture:setDensity(100000)
      objectB.object.physics.body:setFixedRotation(false)
      objectB.object.physics.body:resetMassData()
      
      objectA.object.physics.fixture:setDensity(0)      
      objectA.object.physics.body:resetMassData()
      
      self.tileMap:dispatchEvent(MapEvent.EVENT_COLLISION_BEGIN, objects)
      
    end         
  end
	
	if phase == MOAIBox2DArbiter.END then
      self.tileMap:dispatchEvent(MapEvent.EVENT_COLLISION_END)      
	end
	
end
--
-- 
--
function MapObject:startWalkAnim(direction)
    direction = direction or self.direction    
    local direction = MapObject.DIR_TO_ANIM[direction]
    if self.renderer then      
        if not self.renderer:isBusy() or not self.renderer:isCurrentAnim(direction) then                
            self.renderer:playAnim(direction)
        end
    end
end

function MapObject:stopWalkAnim()
    if self.renderer and self.renderer:isBusy() then
        self.renderer:stopAnim()
        self.renderer:setIndex(MapObject.DIR_TO_INDEX[self.direction])
    end
end

function MapObject:startWalk(direction, speed, count)
    self.lastDirection = self.direction
    self:setDirection(direction)
    self:setSpeed(direction)
    self:startWalkAnim()
    self.walkingCount = count
    if not self.walking then
        self.walking = true        
        self:dispatchEvent(MapObject.EVENT_WALK_START)        
    end       
end

function MapObject:stopWalk()
    self:setSpeed(0)
    self:stopWalkAnim()    
    self.walkingCount = nil
    if self.walking then
        self.walking = false
        self:dispatchEvent(MapObject.EVENT_WALK_STOP)
    end
end


function MapObject:setSpeed(direction)
    if not direction or direction == 0 then
      self.speedX = 0
      self.speedY = 0
      return 
    end
  
    local velocity = self.DIR_TO_VELOCITY[direction]        
    local moveSpeed = self.MOVE_SPEED           
    
    self.speedX = 0
    self.speedX = moveSpeed * velocity.x    

    self.speedY = 0
    self.speedY = moveSpeed * velocity.y        
end

function MapObject:onUpdate()
    self:setPriority(self:vertexZ())      
end
--
--
--
function MapObject:getMapPos()
    return self.mapX, self.mapY
end

function MapObject:toHotSpot(hotSpot)    
    local posX, posY = self.tileMap:getPositionHotSpot(hotSpot)    
    self.physics.body:setTransform(posX,posY)
end

function MapObject:getDirectionByIndex()
    if not self.renderer then
        return
    end

    local index = self.renderer:getIndex()
    if 1 <= index and index <= 3 then
        return "walkDown"
    end
    if 4 <= index and index <= 6 then
        return "walkLeft"
    end
    if 7 <= index and index <= 9 then
        return "walkRight"
    end
    if 10 <= index and index <= 12 then
        return "walkUp"
    end
end


function MapObject:setDirection(dir)          
    self.direction = dir    
end

function MapObject:getDirection()   
    return self.direction
end

function MapObject:vertexZ()     
  local px,py = self:getIsoPos() 
  local z = (py/32) * self.tileMap.mapWidth + (px/32) + 5
  return z  
end




return M