----------------------------------------------------------------------------------------------------
-- Simple example RPGMap.
--
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "hanappe/flower"
local tiled = require "hanappe/extensions/tiled"
local class = flower.class
local table = flower.table
local Layer = flower.Layer
local InputMgr = flower.InputMgr
local Camera = flower.Camera
local TileMap = tiled.TileMap
local TileObject = tiled.TileObject
local ClassFactory = flower.ClassFactory
local Group = flower.Group
local Avatar = require "hanappe/class/Avatar"

-- VARIABLES GUI
local UIView = widget.UIView
local Joystick = widget.Joystick
local Button = widget.Button
local ImageButton = widget.ImageButton
-- class
local RPGMap
local MapObject
local PlayerController
local RPGMapControlView
--local UpdatingSystem
local MovementSystem
local CameraSystem
local RenderSystem
--local ActorController


-- KeyCode
local KeyCode = {}
KeyCode.LEFT = string.byte("a")
KeyCode.RIGHT = string.byte("d")
KeyCode.UP = string.byte("w")
KeyCode.DOWN = string.byte("s")

-- stick to dir map
local STICK_TO_DIR = {
    top = "north",    
    left = "west",
    right = "east",
    bottom = "south"    
}

----------------------------------------------------------------------------------------------------
-- @type RPGMap
----------------------------------------------------------------------------------------------------
RPGMap = class(TileMap)
M.RPGMap = RPGMap

function RPGMap:init()
    TileMap.init(self)
    self.objectFactory = ClassFactory(MapObject)
    
    
    RPGMap.WORLD = nil
    self.objectLayer = nil
    self.collisionLayer = nil
    self.avatar = nil
    
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
    self.camera:addLoc(-400,-150,0)
    self:setLayer(layer)
end

function RPGMap:initPhysics()
    local world = MOAIBox2DWorld.new ()
    world:setGravity ( 0, 0 )
    world:setUnitsToMeters ( 1/30)
    --world:setDebugDrawEnabled(false)
    world:start()
    RPGMap.WORLD = world
    self.layer:setBox2DWorld(RPGMap.WORLD)
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
        --UpdatingSystem(self),
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
    if self.collisionLayer then
        self.collisionLayer:setVisible(false)
        self:createPhysicsCollision()
    end
    if self.objectLayer then
       -- self:createAvatar()
    end
    
    if self.eventLayer then
      self:createPhysicsEvent()
    end  
    
    self:setInvisibleLayerByName("MapBackground")
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
      local body = RPGMap.WORLD:addBody(MOAIBox2DBody.KINEMATIC)        
      local posX,posY = object:getPos()
      local width, height = object:getSize()
      local xMin, yMin, xMax, yMax = -width / 2, -height / 2, width / 2, height / 2   
      
      object:setPos(xMin, yMin)
      object:setParent(body)   
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
      
      object.physics.body = body
  end
end


function RPGMap:createPhysicsCollision()
  for i, object in ipairs(self.collisionLayer.children) do         
    for y = 0, self.mapHeight - 1 do
      for x = 0, self.mapWidth - 1 do
        objeto = object.renderers[y * self.mapWidth + x + 1]
        if objeto then
          local body = RPGMap.WORLD:addBody(MOAIBox2DBody.STATIC)        
          local posX,posY = objeto:getPos()
          local width, height = objeto:getSize()
          local xMin, yMin, xMax, yMax = -width / 2, -height / 2, width / 2, height / 2   
          
          objeto:setPos(xMin, yMin)
          objeto:setParent(body)   
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
end

function UpdatingSystem:onUpdate() 
    local objectLayer = self.tileMap:findMapLayerByName('Object')
    for i, object in ipairs(objectLayer:getObjects()) do
        if object.controller then
            object:onUpdate()
        end
    end
end


----------------------------------------------------------------------------------------------------
-- @type MovementSystem
----------------------------------------------------------------------------------------------------
MovementSystem = class()

function MovementSystem:init(tileMap)
    self.tileMap = tileMap    
end

function MovementSystem:onUpdate()
    for i, object in ipairs(self.tileMap.objectLayer:getObjects()) do
        self:moveObject(object)
    end
end

function MovementSystem:moveObject(object)  
    
    --VERIFICA SE TEM CONTROLLER E SE ESTÁ SE MOVIMENTANDO 
    if not object.controller then      
        return
    end
    
    object.controller:moveObject()
end

--------------------------------------------------------------------------------
-- @type RPGMapControlView
--------------------------------------------------------------------------------
RPGMapControlView = class(UIView)
M.RPGMapControlView = RPGMapControlView

RPGMapControlView.JOYSTICK = nil
RPGMapControlView.ENTER_BUTTON = nil
RPGMapControlView.OPTION_BUTTON = nil
RPGMapControlView.PROFILE_BUTTON = nil


function RPGMapControlView:_createChildren()
    RPGMapControlView.__super._createChildren(self)

    --JOYSTICK
    self.joystick = Joystick {
        stickMode = "digital",
        parent = self,        
        color = {0.6, 0.6, 0.6, 0.6},
        OnStickChanged = function(e)          
          self:dispatchEvent('OnStickChanged', e)
        end,
    }
   
    --BUTTON ENTER
    self.enterButton = Button {
        size = {100, 50},
        color = {0.6, 0.6, 0.6, 0.6},
        text = "Enter",
        parent = self,
        onClick = function(e)
            self:dispatchEvent("enter")
        end,
    }
    
    --BUTTON OPTION
    self.optionButton = ImageButton {
        pos = {self:getWidth()-43, 5},
        normalTexture = "skins/bt_option.png",
        selectedTexture = "skins/bt_option_selected.png",
        disabledTexture = "skins/bt_option.png",
        parent = self,
        onClick = function(e)
          self:dispatchEvent("buttonOption_Click")
        end,
    }
    --BUTTON PROFILE
    self.profileButton = ImageButton {
        pos = {self.optionButton:getLeft()-43, 5},
        normalTexture = "skins/bt_profile.png",
        selectedTexture = "skins/bt_profile_selected.png",
        disabledTexture = "skins/bt_profile.png",
        parent = self,
        onClick = function(e)
          self:dispatchEvent("buttonProfile_Click")
        end,
    }
    
    RPGMapControlView.JOYSTICK = self.joystick    
    RPGMapControlView.ENTER_BUTTON = self.enterButton
    RPGMapControlView.OPTION_BUTTON = self.optionButton
    RPGMapControlView.PROFILE_BUTTON = self.profileButton
end

function RPGMapControlView:updateLayout()
    local vw, vh = flower.getViewSize()
    
    local joystick = RPGMapControlView.JOYSTICK
    local enterButton = RPGMapControlView.ENTER_BUTTON
    local optionButton = RPGMapControlView.OPTION_BUTTON
    local profileButton = RPGMapControlView.PROFILE_BUTTON         
        
    joystick:setPos(10, vh - joystick:getHeight() - 10)
    enterButton:setPos(vw - enterButton:getWidth() - 10, vh - enterButton:getHeight() - 10)
    
    optionButton:setPos(vw-43, 5)
    profileButton:setPos(optionButton:getLeft()-43, 5)
end

function RPGMapControlView:updateDisplay()
    RPGMapControlView.__super.updateDisplay(self)
    
    local vw, vh = flower.getViewSize()
    local joystick = self.joystick
    local enterButton = self.enterButton
    
    joystick:setPos(10, vh - joystick:getHeight() - 10)
    enterButton:setPos(vw - enterButton:getWidth() - 10, vh - enterButton:getHeight() - 10)
end

function RPGMapControlView:getDirection()
    if InputMgr:keyIsDown(KeyCode.LEFT) then
        return "left"
    end
    if InputMgr:keyIsDown(KeyCode.UP) then
        return "up"
    end
    if InputMgr:keyIsDown(KeyCode.RIGHT) then
        return "right"
    end
    if InputMgr:keyIsDown(KeyCode.DOWN) then
        return "down"
    end
    return STICK_TO_DIR[self.joystick:getStickDirection()]
end

--------------------------------------------------------------------------------
-- @type RPGMapPlayerInfo
--------------------------------------------------------------------------------
RPGMapPlayerInfo = class(UIView)
M.RPGMapPlayerInfo = RPGMapPlayerInfo

RPGMapPlayerInfo.NAME = "null"
RPGMapPlayerInfo.XP = 0 

function RPGMapPlayerInfo:_createChildren()
    RPGMapPlayerInfo.__super._createChildren(self)
    
    self.playerPanel = widget.Panel {
        size = {250, 90},
        pos = {5, 5},
        parent = self,
        backgroundTexture = "skins/panel_playerinfo.png",
        backgroundVisible = "skins/panel_playerinfo.png"
    }
    
    -- AVATAR IMAGE
    self.avatarImage = flower.NineImage("avatars/avatar5.png")
    self.avatarImage:setPos(0,0)
    self.avatarImage:setSize(80,85)
    self.playerPanel:addChild(self.avatarImage)  
    
    self.lbNome = flower.Label(RPGMapPlayerInfo.NAME, 100, 30, "arial-rounded.ttf")    
    self.lbNome:setPos(80,5)
    self.playerPanel:addChild(self.lbNome)
    
    self.labelLVL = flower.Label("LVL", 100, 30, "arial-rounded.ttf",14)
    self.labelLVL:setPos(80,35)
    self.playerPanel:addChild(self.labelLVL)    
      
    self.lbLVL = flower.Label(tostring(RPGMapPlayerInfo.XP), 100, 30, "arial-rounded.ttf",18)    
    self.lbLVL:setPos(112,33)
    self.playerPanel:addChild(self.lbLVL)    

    self.barXP = flower.NineImage("skins/barXp.png")
    self.barXP:setPos(80,55)
    self.barXP:setSize(165,26)
    self.playerPanel:addChild(self.barXP)  

    self.barXPbar = flower.NineImage("skins/barXpbar.png")
    self.barXPbar:setPos(124,57)
    self.barXPbar:setSize(80,22)
    self.playerPanel:addChild(self.barXPbar)
end

function RPGMapPlayerInfo:updateDisplay()
    RPGMapPlayerInfo.__super.updateDisplay(self)
    
    local vw, vh = flower.getViewSize()    
end

function RPGMapPlayerInfo:setName(name)
  RPGMapPlayerInfo.NAME = name
  
end
function RPGMapPlayerInfo:setXP(xp)
  RPGMapPlayerInfo.XP = xp  
end  

function RPGMapPlayerInfo:onUpdate()
    self.lbNome:setString(RPGMapPlayerInfo.NAME)
    self.lbLVL:setString(tostring(RPGMapPlayerInfo.XP))
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
-- @type PlayerController
-- 
----------------------------------------------------------------------------------------------------
PlayerController = class()


PlayerController.ANIM_DATA_LIST = {
    {name = "walkNorth", frames = {2, 3, 4, 5, 6, 7, 8, 9}, sec = 0.1},
    {name = "walkSouth", frames = {38, 39, 40, 41, 42, 43, 44, 45}, sec = 0.1},   
    {name = "walkEast",  frames = {20, 21, 22, 23, 24, 25, 26, 27}, sec = 0.1},
    {name = "walkWest",  frames = {56, 57, 58, 59, 60, 61, 62, 63}, sec = 0.1},
    {name = "walkNortheast", frames = {11, 12, 13, 14, 15, 16, 17, 18}, sec = 0.1},
    {name = "walkNorthwest", frames = {65, 66, 67, 68, 69, 70, 71, 72}, sec = 0.1},        
    {name = "walkSoutheast", frames = {29, 30, 31, 32, 33, 34, 35, 36}, sec = 0.1},
    {name = "walkSouthwest", frames = {47, 48, 49, 50, 51, 52, 53, 54}, sec = 0.1},
}

function PlayerController:init(mapObject)    
    self.mapObject = mapObject
    self:initController()
    self:initEventListeners()    
    self:initPhysics()
    self.mapObject:setIsoPos(320,224)
end

function PlayerController:initEventListeners()
    local obj = self.mapObject
end

function PlayerController:initController()
    local object = self.mapObject
    if object.renderer then
        object.renderer:setPos(-48,-76)        
        object.renderer:setAnimDatas(PlayerController.ANIM_DATA_LIST)
        object:setDirection(object:getDirectionByIndex())
    end
end

function PlayerController:onUpdate()
    
end 
function PlayerController:moveObject()    
    local object = self.mapObject       
    
    object.physics.body:setLinearVelocity(object.speedX, object.speedY)
    object:setPos(object.physics.body:getPosition())
end
function PlayerController:initPhysics()
    local object = self.mapObject
    local poly = {
        0, -16,
        32, 0,
        0, 16,
        -32, 0,
    } 
    object.physics.body = RPGMap.WORLD:addBody(MOAIBox2DBody.DYNAMIC)
    object.renderer:setParent(object.physics.body)
    
    local x,y = object:getPos()
    local width, height = object.renderer:getSize()   
    
    object.physics.body:setTransform(x, y)
    object.physics.fixture = object.physics.body:addPolygon(poly)
    
    object.physics.fixture:setCollisionHandler(function(phase, a, b, arbiter)
                                 self:onCollide(phase, a, b, arbiter)
                              end, MOAIBox2DArbiter.ALL)
    
    object.physics.body:resetMassData() 
end

function PlayerController:getEventCollision(fixture)  
  for i, object in ipairs(self.mapObject.tileMap:findMapLayerByName("Event").children) do     
    if object.physics.fixture == fixture then
      return object
    end    
  end
  return nil
end

function PlayerController:onCollide(phase, fixtureA, fixtureB, arbiter)
  local object = self:getEventCollision(fixtureB)
  
  if phase == MOAIBox2DArbiter.BEGIN then           
    if object then
      self.mapObject:dispatchEvent(MapObject.EVENT_COLLISION_BEGIN, object)
    end  
	end
	
	if phase == MOAIBox2DArbiter.END then
    if object then
      self.mapObject:dispatchEvent(MapObject.EVENT_COLLISION_END, object)
    end
	end
	
	if phase == MOAIBox2DArbiter.PRE_SOLVE then
    if object then
      self.mapObject:dispatchEvent(MapObject.EVENT_COLLISION_PRE_SOLVE, object)
    end
	end
	
	if phase == MOAIBox2DArbiter.POST_SOLVE then
    if object then
      self.mapObject:dispatchEvent(MapObject.EVENT_COLLISION_POST_SOLVE, object)
    end
	end
end

----------------------------------------------------------------------------------------------------
-- @type MapObject
----------------------------------------------------------------------------------------------------
MapObject = class(TileObject)
M.MapObject = MapObject


-- Events
MapObject.EVENT_WALK_START = "walkStart"
MapObject.EVENT_WALK_STOP = "walkStop"

MapObject.EVENT_COLLISION_BEGIN = "collisionBegin"
MapObject.EVENT_COLLISION_END = "collisionEnd"
MapObject.EVENT_COLLISION_PRE_SOLVE = "collisionPreSolve"
MapObject.EVENT_COLLISION_POST_SOLVE = "collisionPostSolve"

-- Direction
MapObject.DIR_UP = "north"
MapObject.DIR_LEFT = "west"
MapObject.DIR_RIGHT = "east"
MapObject.DIR_DONW = "south"

-- Move speed
MapObject.MOVE_SPEED = 50

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
    
    if self.type == "Actor" or self.type == "player" then      
       -- self:createPhysics()
       self.controller = PlayerController(self)
      --  self:setPriority(999999)        
    end
end

function MapObject:isWalking()
    return self.walking
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
    self:setDirection(direction)
    self:setSpeed(direction)
    self:startWalkAnim()    
    if not self.walking then
        self.walking = true        
        self:dispatchEvent(MapObject.EVENT_WALK_START)
        self:setPriority(self:vertexZ())
    end
end

function MapObject:stopWalk()
    self:setSpeed(0)
    self:stopWalkAnim()    
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

function MapObject:vertexZ()     
  local px,py = self:getIsoPos() 
  local z = (py/32) * self.tileMap.mapWidth + (px/32) +1
  return z  
end




return M