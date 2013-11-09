----------------------------------------------------------------------------------------------------
-- Módulo dos Mapas Isométricos
--
----------------------------------------------------------------------------------------------------

-- module
local M = {}

----------------------------------------------------------------------------------------------------
-- @type IsoMap
----------------------------------------------------------------------------------------------------
IsoMap = class()
M.IsoMap = IsoMap

function IsoMap:init(tileMap)
    self.tileMap = assert(tileMap)
end

function IsoMap:createPhysicsEvent()  
  for i, object in ipairs(self.tileMap.eventLayer.children) do   
      object.physics = {} 
      local body = self.tileMap.world:addBody(MOAIBox2DBody.KINEMATIC)        
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


function IsoMap:createPhysicsCollision()
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

return M