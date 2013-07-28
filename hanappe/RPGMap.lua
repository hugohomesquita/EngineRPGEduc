----------------------------------------------------------------------------------------------------
-- Simple example RPGMap.
--
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "hanappe/flower"
local tiled = require "hanappe/extensions/tiled"

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
local MapEvent
local MapObject
local RPGMap

local UpdatingSystem
local MovementSystem
local CameraSystem
local RenderSystem

local ActorController
local PlayerController

--------------------------------------------------------------------------------
-- @type MapEvent
-- 
--------------------------------------------------------------------------------
MapEvent = class(Event)
M.MapEvent = MapEvent

MapEvent.EVENT_COLLISION_BEGIN = "collisionBegin"
MapEvent.EVENT_COLLISION_END = "collisionEnd"
MapEvent.EVENT_COLLISION_PRE_SOLVE = "collisionPreSolve"
MapEvent.EVENT_COLLISION_POST_SOLVE = "collisionPostSolve"

MapEvent.TALK = "talk"

MapEvent.TELEPORT = "teleport"

MapEvent.MINIGAME = "minigame"


----------------------------------------------------------------------------------------------------
-- @type RPGMap
----------------------------------------------------------------------------------------------------
RPGMap = class(TileMap)
M.RPGMap = RPGMap

function RPGMap:init()
    TileMap.init(self)
    self.objectFactory = ClassFactory(MapObject)
              
    self.objectLayer = nil
    self.collisionLayer = nil    
    self.worldFreeze = false
    
    self:initLayer()
    self:initPhysics()
    self:initSystems()
    self:initEventListeners()    
end


function RPGMap:initLayer()
    self.camera = Camera()

    local layer = Layer()
    --layer:setPriority(1)
    layer:setSortMode(MOAILayer.SORT_PRIORITY_ASCENDING)
    layer:setCamera(self.camera)
    self.camera:addLoc(-400, -150, 0)
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
        UpdatingSystem(self),
        MovementSystem(self),        
        CameraSystem(self),
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
    self.objectLayer = assert(self:findMapLayerByName("Object"))
    self.playerObject = assert(self.objectLayer:findObjectByName("hugo"))
    self.collisionLayer = assert(self:findMapLayerByName("MapCollision"))
    self.eventLayer = assert(self:findMapLayerByName("Event"))
    self.mapBackgroundLayer = assert(self:findMapLayerByName("MapBackground"))
    
    if self.collisionLayer then
        self.collisionLayer:setVisible(false)
        self:createPhysicsCollision()
    end    
    
    if self.eventLayer then
      self:createPhysicsEvent()
    end  
    
    self.mapBackgroundLayer:setPriority(1)  
   
    --self:setInvisibleLayerByName("MapBackground")
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
-- @type UpdatingSystem
----------------------------------------------------------------------------------------------------
UpdatingSystem = class()

function UpdatingSystem:init(tileMap)    
    self.tileMap = tileMap
    self.tileMap:addEventListener(MapEvent.EVENT_COLLISION_BEGIN, self.onCollisionBegin, self)
    --self.tileMap:addEventListener(MapObject.EVENT_COLLISION_PRE_SOLVE, self.collisionPreSolve, self)
    --self.tileMap:addEventListener(MapObject.EVENT_COLLISION_END, self.onCollisionEnd, self)
end

function UpdatingSystem:onUpdate() 
    for i, object in ipairs(self.tileMap.objectLayer:getObjects()) do
        object:onUpdate()
    end    
end

function UpdatingSystem:onCollisionBegin(e)     
    local object = e.data.objectB    
    if object.type == 'Actor' then
        e.data.objectA:stopWalk()        
        e.data.objectB:stopWalk()        
        self.tileMap:dispatchEvent(MapEvent.TALK, object)        
    end
    if object.type == 'MiniGame' then
        self.tileMap:dispatchEvent(MapEvent.MINIGAME, object)
    end
    if object.type == 'Teleport' then
        self.tileMap:dispatchEvent(MapEvent.TELEPORT, object)
    end
end
function UpdatingSystem:collisionPreSolve(e)  
end
function UpdatingSystem:onCollisionEnd(e)      
end

----------------------------------------------------------------------------------------------------
-- @type MovementSystem
----------------------------------------------------------------------------------------------------
MovementSystem = class()

function MovementSystem:init(tileMap)
    self.tileMap = tileMap    
    
    self.tileMap:addEventListener(MapEvent.EVENT_COLLISION_BEGIN, self.onCollisionBegin, self)
    self.tileMap:addEventListener(MapEvent.EVENT_COLLISION_PRE_SOLVE, self.collisionPreSolve, self)
    self.tileMap:addEventListener(MapEvent.EVENT_COLLISION_END, self.onCollisionEnd, self)
end

function MovementSystem:onUpdate()
    for i, object in ipairs(self.tileMap.objectLayer:getObjects()) do
        self:moveObject(object)
    end
end

function MovementSystem:moveObject(object)         
    
    if not object.controller then      
        return
    end
    
    if object:isColliding() then                      
        return
    end       
  
    object.physics.body:setLinearVelocity(object.speedX, object.speedY)    
    object:setPos(object.physics.body:getPosition())
end

function MovementSystem:onCollisionBegin(e)      
    local object = e.data.objectB    
    if object.type == 'Actor' then      
        
    end    
end
function MovementSystem:collisionPreSolve(e)  
    --print(e.data.name)
    --print(e.data.collisionSide)
end
function MovementSystem:onCollisionEnd(e)  
    
end


----------------------------------------------------------------------------------------------------
-- @type CameraSystem
----------------------------------------------------------------------------------------------------
CameraSystem = class()
CameraSystem.MARGIN_HEIGHT = 140

function CameraSystem:init(tileMap)
    self.tileMap = tileMap
end

function CameraSystem:onLoadedData(e)
    self:onUpdate()
end

function CameraSystem:onUpdate()
    self:scrollCameraToFocusObject()
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
    local x,y = self.tileMap.playerObject:getLoc()
    self:scrollCameraToCenter(x, y)
end

----------------------------------------------------------------------------------------------------
-- @type ActorController
-- 
----------------------------------------------------------------------------------------------------
ActorController = class()

ActorController.ANIM_DATA_LIST = {
    {name = "walkNorth", frames = {2, 3, 4, 5, 6, 7, 8, 9}, sec = 0.1},
    {name = "walkSouth", frames = {38, 39, 40, 41, 42, 43, 44, 45}, sec = 0.1},   
    {name = "walkEast",  frames = {20, 21, 22, 23, 24, 25, 26, 27}, sec = 0.1},
    {name = "walkWest",  frames = {56, 57, 58, 59, 60, 61, 62, 63}, sec = 0.1},
    {name = "walkNortheast", frames = {11, 12, 13, 14, 15, 16, 17, 18}, sec = 0.1},
    {name = "walkNorthwest", frames = {65, 66, 67, 68, 69, 70, 71, 72}, sec = 0.1},        
    {name = "walkSoutheast", frames = {29, 30, 31, 32, 33, 34, 35, 36}, sec = 0.1},
    {name = "walkSouthwest", frames = {47, 48, 49, 50, 51, 52, 53, 54}, sec = 0.1},
}

function ActorController:init(mapObject)    
    self.mapObject = mapObject
    self:initController()
    self:initEventListeners()    
    self:initPhysics()
    --self.mapObject:setIsoPos(320,224)
    self.move = true
    self.currentMove = "north"
    self.nextMove = "south"    
    --self.ia = true
end

function ActorController:initController()
    local object = self.mapObject
    if object.renderer then
        object.renderer:setPos(-48,-76)        
        object.renderer:setAnimDatas(ActorController.ANIM_DATA_LIST)
        object:setDirection(object:getDirectionByIndex())
    end
end

function ActorController:initEventListeners()
    local obj = self.mapObject
end

function ActorController:initPhysics()
    local object = self.mapObject
    local poly = {
        0, -16,
        32, 0,
        0, 16,
        -32, 0,
    } 
    object.physics.body = object.tileMap.world:addBody(MOAIBox2DBody.DYNAMIC)
    object.physics.body.object = object
    object.renderer:setParent(object.physics.body,"notAttr")
    
    local x,y = object:getPos()
    local width, height = object.renderer:getSize()   
    
    object.physics.body:setTransform(x, y)
    object.physics.fixture = object.physics.body:addPolygon(poly)
    object.physics.fixture:setDensity(0)
    object.physics.fixture:setFriction(0)
    object.physics.fixture:setRestitution(0)
    object.physics.fixture:setSensor(false)    
    object.physics.body:resetMassData()     
end

function ActorController:onUpdate()
    --self.mapObject:setPriority(self:vertexZ())
end  

----------------------------------------------------------------------------------------------------
-- @type PlayerController
-- 
----------------------------------------------------------------------------------------------------
PlayerController = class(ActorController)

function PlayerController:initController()
    PlayerController.__super.initController(self)    
    self.player = repositry:getPlayerById(1)
    self.entity = self.player.actor
end

function PlayerController:onUpdate()
    
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
    
    if self.type == "Player" then
        self.controller = PlayerController(self)        
        self.physics.fixture:setCollisionHandler(function(phase, a, b, arbiter)
                                 self:onCollide(phase, a, b, arbiter)
                              end, MOAIBox2DArbiter.ALL)
    elseif self.type == "Actor" then            
        self.controller = ActorController(self)
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
	
	if phase == MOAIBox2DArbiter.PRE_SOLVE then            
    --self.mapObject.tileMap:dispatchEvent(MapObject.EVENT_COLLISION_PRE_SOLVE, event)      
	end
	
	if phase == MOAIBox2DArbiter.POST_SOLVE then    
    --self.mapObject.tileMap:dispatchEvent(MapObject.EVENT_COLLISION_POST_SOLVE, event)     
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
  local z = (py/32) * self.tileMap.mapWidth + (px/32) +1
  return z  
end




return M