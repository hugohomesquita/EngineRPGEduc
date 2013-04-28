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

M.STATES = {
  IDLE = "IDLE",
  WALKING = "WALKING",
}
--WALKING = "WALKING"
function M:init(params)
    TileObject.init(self,params.tileMap)
    self.worldPhysics = params.worldPhysics      
    
    self.name = "HugoHenrique"
    self.controllerName = "AvatarController" 
    self.controller = nil    
    self.renderer = nil       
    self.physics = {}
    self.STATS = M.STATES.IDLE
    self.tileWidth = 96 --28 --64 
    self.tileHeight = 96 -- 56 --32    
    --ATRIBUTOS DE MOVIMENTAÇÃO
    self.mapTileWidth = self.tileMap.tileWidth
    self.mapTileHeight = self.tileMap.tileHeight
    self.move = true
        
    self.moveSpeed = 1
    self.currentDirection = nil
    self.currentMoveX = 0
    self.currentMoveY = 0         
    
    self:setIsoPos(288,256)
    self:setSize(self.tileWidth,self.tileHeight)       
    self:createRenderer()
    self:setPriority(8000)
    self:createPhysics()
    self:createController()   
    --print(self:getMapIsoPos())
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
    self.physics.body:resetMassData() 
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
    
   -- rendererObject:setPos(self.tileWidth-(self.tileWidth/4),-(self.tileHeight+16))
    rendererObject:setPos(-48,-self:getHeight()+16)--ANCORA NOS PÉS
    -- rendererObject:setPos(self.tileWidth+8,-(self.tileHeight+12))  PROFESSOR_2.PNG
    --rendererObject:setPos(0,-self:getHeight()) -- OBJETOS COM ÂNCORA CIMA* 
    
    self.renderer = rendererObject
    
    if self.renderer then
        self:addChild(self.renderer)
    end
    
end

function M:vertexZ()
  local lowestZ = self.tileMap.mapWidth + self.tileMap.mapHeight
  local tilePosX,tilePosY = self:getMapIsoPos()      
  local currentZ =  tilePosX + (tilePosY*(lowestZ/2)) - 40  
  local vertexZ = currentZ 
  return vertexZ  
end

function M:onUpdate()  

end





return M