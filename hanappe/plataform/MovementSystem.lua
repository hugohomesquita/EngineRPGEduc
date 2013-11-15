----------------------------------------------------------------------------------------------------
-- @type MovementSystem
----------------------------------------------------------------------------------------------------
local flower = require "hanappe/flower"
local MapEvent = require "hanappe/MapEvent"

local class = flower.class

local MovementSystem = class()

function MovementSystem:init(tileMap)
    self.tileMap = assert(tileMap)
    
    self.tileMap:addEventListener(MapEvent.EVENT_COLLISION_BEGIN, self.onCollisionBegin, self)
    self.tileMap:addEventListener(MapEvent.EVENT_COLLISION_PRE_SOLVE, self.collisionPreSolve, self)
    self.tileMap:addEventListener(MapEvent.EVENT_COLLISION_END, self.onCollisionEnd, self)
end

function MovementSystem:onUpdate()
    for i, object in ipairs(self.tileMap.mapActorLayer:getObjects()) do
        self:moveObject(object)
        object:onUpdate()
    end
end

function MovementSystem:moveObject(object)             
    if not object.controller then      
        return
    end
    
    if object:isColliding() then                      
        return
    end       
    
    if object.physics.body then
        object.physics.body:setLinearVelocity(object.speedX, object.speedY)    
        object:setPos(object.physics.body:getPosition())
    end
end

function MovementSystem:onCollisionBegin(e)            
    local object = e.data.objectB        
    if object.type == 'Actor' and object.name ~= "Player" then               
        e.data.objectB:stopWalk()            
        self.tileMap:dispatchEvent(MapEvent.TALK, object)        
    end
    if object.type == 'minigame' then
        self.tileMap:dispatchEvent(MapEvent.MINIGAME, object)
    end
    if object.type == 'teleport' then        
        self.tileMap:dispatchEvent(MapEvent.TELEPORT, object)        
    end        
    if object:getProperty("sound") ~= nil then          
        sound = {}        
        sound.looping = object:getProperty("sound_loop")        
        sound.volume = tonumber(object:getProperty("sound_volume")) or 1
        sound.file = object:getProperty("sound")
        self.tileMap:dispatchEvent(MapEvent.SOUND, sound)                 
    end        
                                          
    e.data.objectA:stopWalk()
end
function MovementSystem:collisionPreSolve(e)  
    --print(e.data.name)
    --print(e.data.collisionSide)
end
function MovementSystem:onCollisionEnd(e)      
end

return MovementSystem