module(..., package.seeall)

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------
local Avatar = require "hanappe/class/Avatar"
local FpsMonitor = require "hanappe/extensions/FpsMonitor"

local AVATAR = nil
local MAPA = nil
local PHYSICS = nil

local fpsMonitor = FpsMonitor(1)
function onCreate(e)    
    --fpsMonitor:play() 
    MapLayer = flower.Layer()
    MapLayer:setScene(scene)
    MapLayer:setTouchEnabled(true)
    MapLayer:setPriority(1)
    
    camera = flower.Camera()
    MapLayer:setCamera(camera)
    --camera:addLoc(500,500,0)
    
    
    createHUD()
    PHYSICS = createWorldPhysics()
    MAPA = initMap()
    initAvatar()                  
  
    scrollCameraToFocusObject()
    
end


function initAvatar()
    AVATAR = Avatar({tileMap=MAPA,worldPhysics=PHYSICS})
    AVATAR:addEventListener("collisionBegin",onCollisionBegin)    
    AVATAR:addEventListener("collisionEnd",onCollisionEnd)
    MAPA.objectLayer:addObject(AVATAR)    
    MAPA.avatar = AVATAR
end

function initMap()    
   -- TODO: Tile Map Editor 0.9 Bug
    local mapData = dofile("assets/flare.lue")
    mapData.tilesets[7].tileoffsetx = 0
    mapData.tilesets[7].tileoffsety = 48
    
    mapData.tilesets[4].tileoffsetx = 0
    mapData.tilesets[4].tileoffsety = 16
    
    local mapa = rpgmap.RPGMap()
    mapa:setWorldPhysics(PHYSICS)
    mapa:loadMapData(mapData)
    mapa:setLayer(MapLayer)
    
    --PRIORIDADES DE RENDERIZAÇÃO
    mapa:updateRenderOrdem()
    MapLayer:setBox2DWorld (PHYSICS)

    return mapa
end

colidindo = false

function onCollisionBegin(e)  
  
  
  if e.data.type == 'teleport' and not colidindo then
      local toMap = e.data:getProperty('ToMap')
      local ToMapHotSpot = e.data:getProperty('ToMapHotSpot')
      if toMap and toMpa ~= MAPA:getProperty('name')  and ToMapHotSpot then
        colidindo = true
        changeMap(toMap,ToMapHotSpot)
      end
  end
  if e.data.type == 'on_load' then
      USER_DATA.xp = USER_DATA.xp + 20
  end
  
  if e.data.type == 'minigame' then
    clase = require "minigames/quiz"
    MINIGAME = flower.openScene("minigames/quiz", {sceneFactory = flower.ClassFactory(clase)}) 
    MINIGAME:addEventListener("onClose",onCloseMiniGame)
    stopWorld()
  end
end
function onCloseMiniGame(e)    
    USER_DATA.xp = USER_DATA.xp + e.data.XP
    PHYSICS:start()
end
function onCollisionEnd(e)
  colidindo = false
end
function changeMap(toMap,ToMapHotSpot)   
   local mapName = assert(toMap)
   local hotspot = assert(ToMapHotSpot)
   
   local mapFile = dofile("assets/"..mapName..".lue")
   --REINICIANDO FÍSICA
   PHYSICS = createWorldPhysics()
   
   
   local mapData = rpgmap.RPGMap()
   mapData:setWorldPhysics(PHYSICS) --MUDAR E COLOCAR NO CONSTRUTOR
   mapData:loadMapData(mapFile)
   
   local px,py = mapData:getPositionHotSpot(hotspot)
   
   --LIMPANDO A LAYER

   MapLayer:clear()
   
   
   
   
   AVATAR:setWorldPhysics(PHYSICS)
      
   AVATAR:toPos(px,py)
   mapData:setLayer(MapLayer)
  
   --PRIORIDADES DE RENDERIZAÇÃO
   mapData:updateRenderOrdem()

   
   AVATAR:setTileMap(mapData)
   mapData.objectLayer:addObject(AVATAR)    
   mapData.avatar = AVATAR
    
   MapLayer:setBox2DWorld (PHYSICS)
   MAPA = mapData
   --layer:removeProp(image1)
end

function createWorldPhysics()
    local world = MOAIBox2DWorld.new ()
    world:setGravity ( 0, 0 )
    world:setUnitsToMeters ( 1/30)
    --world:setDebugDrawEnabled(false)
    world:start()
    return world
end

function createHUD()
    view = widget.UIView {
        scene = scene,
    }
    --HUD
    infoBar = widget.UIGroup {
      size = {100,100},
      parent = view,
      pos = {10,10},
    }
    
    --LOAD PLAYER INFO
    
    GAME_FILE = savefiles.get "user"
    USER_DATA = GAME_FILE.data
    
    lbNome = flower.Label(USER_DATA.nome, 100, 30, "arial-rounded.ttf")    
    lbNome:setPos(0,0)
    view:addChild(lbNome)
    
    lbXP = flower.Label("XP:"..USER_DATA.xp, 100, 30, "arial-rounded.ttf",18)    
    lbXP:setPos(0,30)
    view:addChild(lbXP)
    
    --CONTROLES
    joystick = widget.Joystick {
        stickMode = "digital",
        parent = view,
        onStickChanged = joystick_OnStickChanged,
    }
    joystick:setPos(5, flower.viewHeight - joystick:getHeight() - 5)
end

function updateHUD()
    lbXP:setString("XP:"..tostring(USER_DATA.xp))
end

function scrollCameraToCenter(x, y)
    local cx, cy = flower.getViewSize()
    scrollCamera(x - (cx/2), y - (cy/2))    
end
function scrollCamera(x, y)
  nx,ny = math.floor(x), math.floor(y)
  camera:setLoc(nx,ny)
end
function scrollCameraToFocusObject()
    local x,y = MAPA.avatar:getLoc()
    scrollCameraToCenter(x, y)
end

function onStart(e)
  
end

function stopWorld()
  joystick:setCenterKnob()
  e = {}
  
  e.direction = "center"
  MAPA.avatar.controller:walkByStick(e)
  PHYSICS:stop()
end

function joystick_OnStickChanged(e)
    MAPA.avatar.controller:walkByStick(e)    
end

function onUpdate(e)  
  MAPA:onUpdate(e) 
  updateHUD()
  scrollCameraToFocusObject()
end

