----------------------------------------------------------------------------------------------------
-- @type AvatarController
----------------------------------------------------------------------------------------------------

--  IMPORTS
local flower = require "hanappe/flower"
local tiled = require "hanappe/extensions/tiled"
local Avatar = require "hanappe/class/Avatar"
--  INSTANTIATION
local class = flower.class
--local Group = flower.Group

local M = class()

local ANIM_DATAS = {
    {name = "walkNorth", frames = {2, 3, 4, 5, 6, 7, 8, 9}, sec = 0.1},
    {name = "walkSouth", frames = {38, 39, 40, 41, 42, 43, 44, 45}, sec = 0.1},   
    {name = "walkEast",  frames = {20, 21, 22, 23, 24, 25, 26, 27}, sec = 0.1},
    {name = "walkWest",  frames = {56, 57, 58, 59, 60, 61, 62, 63}, sec = 0.1},    
    {name = "walkNortheast", frames = {11, 12, 13, 14, 15, 16, 17, 18}, sec = 0.1},
    {name = "walkNorthwest", frames = {65, 66, 67, 68, 69, 70, 71, 72}, sec = 0.1},        
    {name = "walkSoutheast", frames = {29, 30, 31, 32, 33, 34, 35, 36}, sec = 0.1},
    {name = "walkSouthwest", frames = {47, 48, 49, 50, 51, 52, 53, 54}, sec = 0.1},
}

local DIRECTIONS_DATA = {
    walkNorth = {index = 1},
    walkSouth = {index = 37},   
    walkEast = {index = 19},
    walkWest = {index = 55},    
    walkNortheast ={index = 10},
    walkNorthwest = {index = 64},        
    walkSoutheast = {index = 28},
    walkSouthwest = {index = 46},
}
local DIRECTIONS = {
    walkNone = {x = 0, y = 0},
    
    walkNorth = {x = 0, y = -1},
    walkNortheast = {x = 64, y = -32},
    walkNorthwest = {x = -64, y = -32},
    
    walkEast = {x = 1, y = 0},
    walkWest = {x = -1, y = 0},
    
    walkSoutheast = {x = 64, y = 32},
    walkSouth = {x = 0, y = 1},
    walkSouthwest = {x = -64, y = 32},       
}
--EXCLUIR
local DIR = {
    walkNone = {x = 0, y = 0},
    
    walkNorth = {x = 0, y = -1},
    walkNortheast = {x = 1, y = -1},
    walkNorthwest = {x = -1, y = -1},
    
    walkEast = {x = 1, y = 0},
    walkWest = {x = -1, y = 0},
    
    walkSoutheast = {x = 1, y = 1},
    walkSouth = {x = 1, y = 1},
    walkSouthwest = {x = -32, y = 16},       
}

function M:init(tileObject)
    self.tileObject = assert(tileObject)
    self.renderer = tileObject.renderer       
    self.collisionLayer = self.tileObject.tileMap:findMapLayerByName('Collision')
    self.objectLayer = self.tileObject.tileMap:findMapLayerByName('Object')
    if self.renderer then
        self.renderer:setAnimDatas(ANIM_DATAS)
    end         
    self.linearVelocity = {x=0,y=0}
end


function M:moveStep()
    if not self.tileObject.move then
      self.tileObject.physics.body:setLinearVelocity(0,0)
      return
    end

    local velocity = self.tileObject.controller.linearVelocity
    x = velocity.x 
    y = velocity.y
    self.tileObject.physics.body:setLinearVelocity(x,y)
    self.tileObject:setPos(self.tileObject.physics.body:getPosition())
end
-- function moveMapLoc-ERPGSPRITE
function M:walk(direction)
    if not self.tileObject.move then      
      return
    end
                       
    self:setDirection(direction) 
    

    
    self.tileObject.currentMoveX = DIRECTIONS[direction].x * self.tileObject.moveSpeed
    self.tileObject.currentMoveY = DIRECTIONS[direction].y * self.tileObject.moveSpeed
    self.linearVelocity = {
      x = self.tileObject.currentMoveX,
      y = self.tileObject.currentMoveY,
    }
end

function M:setDirection(direction)
    --if self.tileObject:isMoving() then
     --   return
    --end
    --if self.tileObject.currentDirection == direction then
    --    return
    --end
    --print('teste')
    self.tileObject.currentDirection = direction
    --print(direction)
    --local animName = ACTOR_ANIM_DATAS[direction]
    --print(animName)
    --if direction then
    self.renderer:playAnim(direction) 
   -- end
end


--WALK BY BUTTONS
function M:walkLeft()
    self:walk("walkWest")
end

function M:walkUp()
    self:walk("walkNorth")
end

function M:walkEast()
    self:walk("walkEast")
end

function M:walkSouth()  
    self:walk("walkSouth")
end


function M:round(n, mult)
    mult = mult or 1
    return math.floor((n + mult/2)/mult) * mult
end

function M:walkByStick(e)        
    --print(e.down)
    if e.direction == 'center' then            
      self.linearVelocity.x = 0
      self.linearVelocity.y = 0
      self.renderer:stopAnim()    
      --self.renderer:setIndex(DIRECTIONS_DATA[self.tileObject.currentDirection].index)
      return  
    end
    
    local x,y = self:round(e.newX), self:round(e.newY)
    if x == 0 and y == -1 then  
      self:walk("walkNortheast")
      --self:walk("walkNorth")  
    elseif x == 0 and y == 1 then
      --self:walk("walkSouth")   
      self:walk("walkSouthwest")
    elseif x == -1 and y == 0 then
      --self:walk("walkWest")
      self:walk("walkNorthwest")
    elseif x == 1 and y == 0 then
      self:walk("walkSoutheast")
      --self:walk("walkEast")
    elseif x == -1 and y == -1 then
      self:walk("walkNorthwest")
    elseif x == 1 and y == -1 then
      self:walk("walkNortheast")
    elseif x == -1 and y == 1 then  
      self:walk("walkSouthwest")
    elseif x == 1 and y == 1 then
      self:walk("walkSoutheast")
    end

end

return M