----------------------------------------------------------------------------------------------------
-- @type Avatar
----------------------------------------------------------------------------------------------------
--  IMPORTS
local flower = require "hanappe/flower"
local tiled = require "hanappe/extensions/tiled"

local class = flower.class
local Group = flower.Group
local TileObject = tiled.TileObject

local M = class(TileObject)

-- Events
M.EVENT_COLLISION_BEGIN = "collisionBegin"
M.EVENT_COLLISION_END = "collisionEnd"
M.EVENT_COLLISION_PRE_SOLVE = "collisionPreSolve"
M.EVENT_COLLISION_POST_SOLVE = "collisionPostSolve"

function M:init(params)
    TileObject.init(self,params.tileMap)
    self.worldPhysics = params.worldPhysics      
    self.name = "HugoHenrique"
    self.type = "Player"
    self.controllerName = "AvatarController" 
    self.controller = nil    
    self.renderer = nil       
    self.physics = {}
    self.tileWidth = 96 --28 --64 
    self.tileHeight = 96 -- 56 --32    
    --ATRIBUTOS DE MOVIMENTAÇÃO
    self.mapTileWidth = self.tileMap.tileWidth
    self.mapTileHeight = self.tileMap.tileHeight
    self.move = true
        
    self.moveSpeed = 1
    self.currentDirection = walkSouth
    self.currentMoveX = 0
    self.currentMoveY = 0         
    
    self:setIsoPos(288,256)
    self:setSize(self.tileWidth,self.tileHeight)       
    
    self:createRenderer()    
    self:createPhysics()
    self:createController()   
    --self.renderer:setPriority(5)

end

function M:toPos(x,y)
    self:setIsoPos(x,y)  
    self:createRenderer()  
    self:createPhysics()    
    self:createController() 
end

function M:setTileMap(tileMap)
    self.tileMap = tileMap
end
function M:setWorldPhysics(worldPhysics)
    self.worldPhysics = worldPhysics
end

function M:createController(worldPhysics)  
    local controllerName = self:getProperty("controller") or self.controllerName   
    if not controllerName then
      return
    end      

    local controllerClass = require("hanappe/class/"..controllerName)    
    if controllerClass then
        self.controller = controllerClass(self,worldPhysics)
    end
end

function M:createPhysics()    
    local poly = {
        0, -8,
        16, 0,
        0, 8,
        -16, 0,
      }         
    local poly2 = {
        0, -16,
        32, 0,
        0, 16,
        -32, 0,
      } 
    self.physics.body = self.worldPhysics:addBody(MOAIBox2DBody.DYNAMIC)
    self.renderer:setParent(self.physics.body)
    
    local x,y = self:getPos()
    local width, height = self.renderer:getSize()
    local xMin, yMin, xMax, yMax = -width / 2, -height / 2, width / 2, height / 2 
    
    self.physics.body:setTransform(x, y)
    self.physics.fixture = self.physics.body:addPolygon(poly2)
    
    self.physics.fixture:setCollisionHandler(function(phase, a, b, arbiter)
                                 self:onCollide(phase, a, b, arbiter)
                              end, MOAIBox2DArbiter.ALL)
    
    self.physics.body:resetMassData() 
end

function M:getEventCollision(fixture)
  for i, object in ipairs(self.tileMap:findMapLayerByName("Event").children) do     
    if object.physics.fixture == fixture then
      return object
    end    
  end
  return nil
end

function M:onCollide(phase, fixtureA, fixtureB, arbiter)
  local object = self:getEventCollision(fixtureB)
  
  if phase == MOAIBox2DArbiter.BEGIN then       
    if object then
      self:dispatchEvent(M.EVENT_COLLISION_BEGIN, object)
    end  
	end
	
	if phase == MOAIBox2DArbiter.END then
    if object then
      self:dispatchEvent(M.EVENT_COLLISION_END, object)
    end
	end
	
	if phase == MOAIBox2DArbiter.PRE_SOLVE then
    if object then
      self:dispatchEvent(M.EVENT_COLLISION_PRE_SOLVE, object)
    end
	end
	
	if phase == MOAIBox2DArbiter.POST_SOLVE then
    if object then
      self:dispatchEvent(M.EVENT_COLLISION_POST_SOLVE, object)
    end
	end
end


function M:getController()
    return self.controller
end

function M:getMapPos()
    local posX, posY = self:getPos()
    posX = posX - self.tileMap.tileWidth / 2
    posY = posY - self.tileMap.tileHeight / 2
    local y = posY - posX / 2
    local x = posX + y
    return math.floor((x + self.tileMap.tileHeight / 2)/32), math.floor((y+self.tileMap.tileHeight / 2)/32)
end


function M:createRenderer()
    if self.renderer then
        self:removeChild(self.renderer)
    end
    local rendererObject = flower.MovieClip("human.png")    
    
    rendererObject:setTileSize(self.tileWidth,self.tileHeight)
    rendererObject:setIndex(1)       
    
    rendererObject:setPos(-48,-self:getHeight()+16)
    
    self.renderer = rendererObject
    
    if self.renderer then
        self:addChild(self.renderer)
    end
    
end

function M:vertexZ()
  local px,py = self:getIsoPos() 
  local z = (py/32) * self.tileMap.mapWidth + (px/32) +1
  return z  
end

function M:onUpdate()
    --ATUALIZANDO A ORDEM DE RENDERIZAÇÃO
    self:setPriority(self:vertexZ())
end


function M:getMapIsoPos()
    local posX, posY = self:getPos()
    posX = posX - self.tileMap.tileWidth / 2
    posY = posY - self.tileMap.tileHeight / 2
    local y = posY - posX / 2
    local x = posX + y
    return math.floor((x + self.tileMap.tileHeight / 2)/32), math.floor((y+self.tileMap.tileHeight / 2)/32)
end


return M