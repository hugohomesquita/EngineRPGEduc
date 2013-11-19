----------------------------------------------------------------------------------------------------
-- @type ActorController
----------------------------------------------------------------------------------------------------
local flower = require "hanappe/flower"
local MapEvent = require "hanappe/MapEvent"
local tiled = require "hanappe/extensions/tiled"
local PlayerController = require "hanappe/plataform/PlayerController"
local class = flower.class
local TileObject = tiled.TileObject
local MapObject = class(TileObject)

-- Events
MapObject.EVENT_WALK_START = "walkStart"
MapObject.EVENT_WALK_STOP = "walkStop"

-- Direction
MapObject.DIR_UP = "north"
MapObject.DIR_LEFT = "west"
MapObject.DIR_RIGHT = "east"
MapObject.DIR_DONW = "south"

-- Move speed
MapObject.MOVE_SPEED = 80

-- Direction to AnimationName
MapObject.ISO_DIR_TO_ANIM = {
    north = "walkNortheast",
    south = "walkSouthwest",
    east = "walkSoutheast",
    west = "walkNorthwest",
}
MapObject.ORT_DIR_TO_ANIM = {
    north = "walkNorth",
    south = "walkSouth",
    east = "walkEast",
    west = "walkWest",
}


MapObject.ISO_DIR_TO_INDEX = {
    north = 10,
    south = 46,
    east = 28,
    west = 64,
}

MapObject.ORT_DIR_TO_INDEX = {
    north = 11,
    south = 2,
    east = 8,
    west = 5,
}

MapObject.ISO_DIR_TO_VELOCITY = {
    north = {x = 1, y = -0.5},    
    west = {x = -1, y = -0.5},
    east = {x = 1, y = 0.5},
    south = {x = -1, y = 0.5},
}

MapObject.ORT_DIR_TO_VELOCITY = {
    north = {x = 0, y = -1},    
    west = {x = -1, y = 0},
    east = {x = 1, y = 0},
    south = {x = 0, y = 1},
}

function MapObject:init(tileMap)
    TileObject.init(self, tileMap)
    self.tileMap = tileMap
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
        if self.physics.fixture and self.name == "Player" then          
            self.physics.fixture:setCollisionHandler(function(phase, a, b, arbiter)
                                 self:onCollide(phase, a, b, arbiter)
                              end, MOAIBox2DArbiter.ALL)
        end
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
    local direction = direction or self.direction    
    
    if self.tileMap:isOrthogonal() then
        direction = MapObject.ORT_DIR_TO_ANIM[direction]
    elseif self.tileMap:isIsometric() then      
        direction = MapObject.ISO_DIR_TO_ANIM[direction]      
    end  
    
    if self.renderer then      
      if not self.renderer:isBusy() or not self.renderer:isCurrentAnim(direction) then                
          self.renderer:playAnim(direction)
      end
    end
end

function MapObject:stopWalkAnim()
    if self.renderer and self.renderer:isBusy() then
        self.renderer:stopAnim()
        if self.tileMap:isOrthogonal() then
          self.renderer:setIndex(MapObject.ORT_DIR_TO_INDEX[self.direction])
        elseif self.tileMap:isIsometric() then
          self.renderer:setIndex(MapObject.ISO_DIR_TO_INDEX[self.direction])
        end
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
  
    
    local velocity = nil                    
    
    if self.tileMap:isOrthogonal() then
        velocity = self.ORT_DIR_TO_VELOCITY[direction]         
    elseif self.tileMap:isIsometric() then      
        velocity = self.ISO_DIR_TO_VELOCITY[direction]       
    end 
    
    local moveSpeed = self.MOVE_SPEED 
    
    if velocity then
        self.speedX = 0
        self.speedX = moveSpeed * velocity.x    

        self.speedY = 0
        self.speedY = moveSpeed * velocity.y        
    end
end

function MapObject:onUpdate()
    if self.tileMap:isIsometric() then
        self:setPriority(self:vertexZ()) 
    end        
end

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
return MapObject