module(..., package.seeall)

local FpsMonitor = require "hanappe/extensions/FpsMonitor"

local entities = require "libs/entities"
local repositry = entities.repositry

local MapControlView = views.MapControlView

local TalkView = views.TalkView

local AvatarInfoBox = widgets.AvatarInfoBox
local BalloonEffect = effects.BalloonEffect

local RPGMap = rpgmap.RPGMap

local mapPlayerInfo = nil
local rpgMap = nil
local worldFreeze  = false
colidindo = false
local fpsMonitor = FpsMonitor(1)

function onCreate(e)           
    flower.Runtime:addEventListener("resize", onResize)
    
    rpgMap = RPGMap()
    rpgMap:setScene(scene)
    rpgMap:addEventListener("talk",onTalk)    
    --rpgMap:addEventListener("minigame",onMinigame)
    
    loadRPGMap("assets/flare.lue")    
    
    playerObject = rpgMap.objectLayer:findObjectByName("hugo")

    --INICIALIZANDO A GUI    
    mapControlView = MapControlView()
    mapControlView:setScene(scene)
    mapControlView:addEventListener("enter", onEnter)
    --mapControlView:addEventListener("OnStickChanged", joystick_OnStickChanged)
    
    mapControlView:addEventListener("buttonProfile_Click", buttonProfile_Click)
    mapControlView:addEventListener("buttonOption_Click", buttonOption_Click)
    
    
    --INFO PLAYER
    player = repositry:getPlayerById(1)
    avatarInfoBox = AvatarInfoBox{
        scene = scene,
        player = player
    }    
               
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


--EVENTOS DO RPGMap

function onEnter(e)
    effect = BalloonEffect(repositry:getEffectById(2))
    effect:play(playerObject)    
end

function onTalk(e)    
    local actor = e.data
    local id = tonumber(actor:getProperty('actor_id')) 
    
    talkView = TalkView {
        actor = repositry:getActorById(id),
        talk = repositry:getTalkById(1),
        scene = scene,        
    }           
    talkView:addEventListener("close", talkView_onClose)
end

function talkView_onClose(e)
    talkView:setVisible(false)
    local actions = e.data.talk:getActionByIdAnswer(e.data.id)        
    if actions.action == "minigame" then
        openMinigame('quiz')
    end      
end

function openMinigame(nameMinigame)
    stopWorld()
    MINIGAME = flower.openScene("minigames/"..nameMinigame , {animation = "overlay"})   
    MINIGAME:addEventListener("closeMinigame", onCloseMiniGame)
end

function onCloseMiniGame(e)    
    startWorld()         
end

function updateHUD()
    avatarInfoBox:updateDisplay()
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
       
  if worldFreeze then
      playerObject:stopWalk()
  end
       
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
    avatarInfoBox:setVisible(false)
end

function onStart(e)
    startWorld()
    mapControlView:setVisible(true)
    avatarInfoBox:setVisible(true)
end

