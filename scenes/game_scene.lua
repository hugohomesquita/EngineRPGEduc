module(..., package.seeall)

local FpsMonitor = require "hanappe/extensions/FpsMonitor"

local entities = require "libs/entities"
local repositry = entities.repositry

local MapControlView = views.MapControlView
local MapPlayerInfo = views.MapPlayerInfo
local BalloonEffect = effects.BalloonEffect

local RPGMap = rpgmap.RPGMap

local mapPlayerInfo = nil
local rpgMap = nil
local worldFreeze  = false

local fpsMonitor = FpsMonitor(1)

function onCreate(e)         
    rpgMap = RPGMap()
    rpgMap:setScene(scene)
    rpgMap:addEventListener("talk",onTalk)    
    rpgMap:addEventListener("minigame",onMinigame)
    
    loadRPGMap("assets/flare.lue")    
    
    playerObject = rpgMap.objectLayer:findObjectByName("hugo")

    --INICIALIZANDO A GUI    
    mapControlView = MapControlView()
    mapControlView:setScene(scene)
    mapControlView:addEventListener("enter", onEnter)
    --mapControlView:addEventListener("OnStickChanged", joystick_OnStickChanged)
    
    mapControlView:addEventListener("buttonProfile_Click", buttonProfile_Click)
    mapControlView:addEventListener("buttonOption_Click", buttonOption_Click)
    
    flower.Runtime:addEventListener("resize", onResize)
    --INFO PLAYER
    mapPlayerInfo = MapPlayerInfo()
    mapPlayerInfo:setScene(scene)
               
end

function loadRPGMap(mapName)
    local mapData = dofile(mapName)
    mapData.tilesets[7].tileoffsetx = 0
    mapData.tilesets[7].tileoffsety = 48
    
    mapData.tilesets[4].tileoffsetx = 0
    mapData.tilesets[4].tileoffsety = 16
    
   -- mapData.tilesets[9].tileoffsetx = 32
    --mapData.tilesets[9].tileoffsety = 96
    
    rpgMap:loadMapData(mapData)
    playerObject = rpgMap.objectLayer:findObjectByName("Player")
end

function onResize(e)
  --RPGMapPlayerInfo:updateDisplay()
   RPGMapControlView:updateLayout()
end

colidindo = false
--EVENTOS DO RPGMap

function onEnter(e)
    effect = BalloonEffect(repositry:getEffectById(2))
    effect:play(playerObject)    
end


function onTalk(e)
    flower.openScene(scenes.DIALOG, {animation = "overlay"})
end

function onMinigame(e)
  --print(e.data.name)
  clase = require "minigames/quiz"
  MINIGAME = flower.openScene("minigames/quiz", {sceneFactory = flower.ClassFactory(clase)}) 
  MINIGAME:addEventListener("onClose",onCloseMiniGame)
  stopWorld()
end
function onCloseMiniGame(e)    
    USER_DATA.xp = USER_DATA.xp + e.data.XP
    startWorld()         
end

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
  
end

function updateHUD()
    mapPlayerInfo:onUpdate()
end

---
---   FUNCTIONS
---
function startWorld()
  worldFreeze = false  
  rpgMap:startWorld()
end

function stopWorld()
  worldFreeze = true
  mapControlView:reset()
  rpgMap:stopWorld()
end



--CONTROLLER LISTENER
function buttonProfile_Click(e)
    flower.openScene(menus.PROFILE.name, {animation = menus.PROFILE.animation})
end

function buttonOption_Click(e)  
    flower.openScene(scenes.MENU, {animation = "overlay"})
end



--
--    UPDATES THE GAME  
--

function onUpdate(e)       
  if not worldFreeze then
    updateMap()
    updatePlayer()  
    updateHUD()
  end
end

function updateMap()
    rpgMap:onUpdate(e)
end

function updatePlayer()
    local direction = mapControlView:getDirection()    
    if direction then
        playerObject:startWalk(direction)
    else      
        playerObject:stopWalk()
    end    
end

--
--
--

function onStop(e)
    mapControlView:setVisible(false)
    mapPlayerInfo:setVisible(false)
end

function onStart(e)
    mapControlView:setVisible(true)
    mapPlayerInfo:setVisible(true)
end

