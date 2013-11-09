----------------------------------------------------------------------------------------------------
-- @type ActorController
----------------------------------------------------------------------------------------------------
local flower = require "hanappe/flower"
local MapEvent = require "hanappe/MapEvent"
local tiled = require "hanappe/extensions/tiled"

local class = flower.class
local TileObject = tiled.TileObject
local ActorController = class()

ActorController.ISO_ANIM_DATA_LIST = {
    {name = "walkNorth", frames = {2, 3, 4, 5, 6, 7, 8, 9}, sec = 0.1},
    {name = "walkSouth", frames = {38, 39, 40, 41, 42, 43, 44, 45}, sec = 0.1},   
    {name = "walkEast",  frames = {20, 21, 22, 23, 24, 25, 26, 27}, sec = 0.1},
    {name = "walkWest",  frames = {56, 57, 58, 59, 60, 61, 62, 63}, sec = 0.1},
    {name = "walkNortheast", frames = {11, 12, 13, 14, 15, 16, 17, 18}, sec = 0.1},
    {name = "walkNorthwest", frames = {65, 66, 67, 68, 69, 70, 71, 72}, sec = 0.1},        
    {name = "walkSoutheast", frames = {29, 30, 31, 32, 33, 34, 35, 36}, sec = 0.1},
    {name = "walkSouthwest", frames = {47, 48, 49, 50, 51, 52, 53, 54}, sec = 0.1},
}

ActorController.ORT_ANIM_DATA_LIST = {
    {name = "walkNorth", frames = {11, 10, 11, 12, 11}, sec = 0.25},
    {name = "walkSouth", frames = {2, 1, 2, 3, 2}, sec = 0.25},   
    {name = "walkEast",  frames = {8, 7, 8, 9, 8}, sec = 0.25},
    {name = "walkWest",  frames = {5, 4, 5, 6, 5}, sec = 0.25},    
}

function ActorController:init(mapObject)    
    self.mapObject = mapObject
    self.tileMap = mapObject.tileMap
    
    --self:initEventListeners()    
    self:initController()
    self:initPhysics()
    --self.mapObject:setIsoPos(320,224)
    self.move = true
    self.currentMove = "north"
    self.nextMove = "south"        
end

function ActorController:initController()
    local object = self.mapObject
    
    if self.tileMap:isOrthogonal() then
        if object.renderer then   
            object.renderer:setPos(-8,-16)  
            object.renderer:setAnimDatas(ActorController.ORT_ANIM_DATA_LIST)
            object:setDirection(object:getDirectionByIndex())
        end
    elseif self.tileMap:isIsometric() then
        if object.renderer then
            object.renderer:setPos(-48,-76)        
            object.renderer:setAnimDatas(ActorController.ISO_ANIM_DATA_LIST)
            object:setDirection(object:getDirectionByIndex())
        end
    end
    
end

function ActorController:initEventListeners()
    local obj = self.mapObject
end

function ActorController:initPhysics()
    local object = self.mapObject    
    local poly = nil
    if self.tileMap:isOrthogonal() then
        poly = {
            0, 20,
            0, 0,
            20, 0,
            20, 20,
        } 
    elseif self.tileMap:isIsometric() then       
        poly = {
            0, -10,
            20, 0,
            0, 10,
            -20, 0,
        }                   
    end
    
    local x,y = object:getPos()    
    local width, height = object.renderer:getSize()
       
    object.physics.body = object.tileMap.world:addBody(MOAIBox2DBody.DYNAMIC)
    object.physics.body.object = object
    object.renderer:setParent(object.physics.body, "notAttr")
            
    object.physics.fixture = object.physics.body:addPolygon(poly)
    
    object.physics.body:setTransform(x, y - 32) 
    object.physics.fixture:setDensity(0)
    object.physics.fixture:setFriction(0)
    object.physics.fixture:setRestitution(0)
    object.physics.fixture:setSensor(false)    
    object.physics.body:resetMassData()   
end

return ActorController