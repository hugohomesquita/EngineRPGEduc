----------------------------------------------------------------------------------------------------
-- Módulo de cena mostra o mapa
--
----------------------------------------------------------------------------------------------------

module(..., package.seeall)

-- imports
local entities = require "libs/entities"
local repositry = entities.repositry
local entityPool = entities.entityPool
local RPGMap = rpgmap.RPGMap

-- views
local MapControlView = views.MapControlView
local TalkView = views.TalkView
local AvatarInfoBox = widgets.AvatarInfoBox
-- effects
local BalloonEffect = effects.BalloonEffect

-- variables
local PLAYER_ID = nil
local mapPlayerInfo = nil
local rpgMap = nil
local worldFreeze  = false

function onCreate(e)           
    e.data.PLAYER_ID = 1    
    --assert(e.data.PLAYER_ID)
    
    PLAYER_ID = e.data.PLAYER_ID    
    flower.Runtime:addEventListener("resize", onResize)                
    
    rpgMap = RPGMap()
    rpgMap:setScene(scene)
    rpgMap:addEventListener("talk",onTalk)       
    rpgMap:addEventListener("teleport",onTeleport)
    --rpgMap:addEventListener("minigame",onMinigame)
    
    loadRPGMap("assets/maps/"..e.data.MAP..".lua", e.data.hotSpot)    
    
    playerObject = rpgMap.player

    --INICIALIZANDO A GUI    
    mapControlView = MapControlView()
    mapControlView:setScene(scene)
    mapControlView:addEventListener("enter", onEnter)
    --mapControlView:addEventListener("OnStickChanged", joystick_OnStickChanged)
    
    mapControlView:addEventListener("buttonProfile_Click", buttonProfile_Click)
    mapControlView:addEventListener("buttonOption_Click", buttonOption_Click)
    
    
    --INFO PLAYER
    player = repositry:getPlayerById(PLAYER_ID)
    avatarInfoBox = AvatarInfoBox{
        scene = scene,
        player = player
    }    
               
end

function loadRPGMap(mapName, hotSpot)
    local mapData = dofile(mapName)
    --mapData.tilesets[7].tileoffsetx = 0
    --mapData.tilesets[7].tileoffsety = 48
    
    --mapData.tilesets[4].tileoffsetx = 0
    --mapData.tilesets[4].tileoffsety = 16
    
   -- mapData.tilesets[9].tileoffsetx = 32
    --mapData.tilesets[9].tileoffsety = 96       

    rpgMap:loadMapData(mapData)    
    playerObject = rpgMap.player
    playerObject:toHotSpot(hotSpot)
end


function onResize(e)
  --RPGMapPlayerInfo:updateDisplay()
   mapControlView:updateLayout()
end

function onTeleport(e)    
    stopWorld()
    flower.gotoScene(scenes.LOADING, {
        MAP = e.data:getProperty("toMap"),
        hotSpot = e.data:getProperty("toMapHotSpot"),
        animation = "fade",
        nextSceneName = scenes.GAME,
        nextSceneParams = {animation = "fade"},
    }) 
end
--EVENTOS DO RPGMap
priorite = 0
function onEnter(e)  
      
       
    --for i,layer in  ipairs(rpgMap:getMapLayers()) do
    --  if layer.name == "MapObject" then
    --    print(layer.name)
     --   for i,tile in  ipairs(layer.tiles) do
      --    print(tile)
      --  end
     -- end
    --end
    --priorite = playerObject:getPriority() - 5     
    --playerObject:setPriority(priorite)
    --repositry:savePlayer(1)
    --entityPool:saveEntities(1)
    --repositry:savePlayerById(1,1)
    --effect = BalloonEffect(repositry:getEffectById(2))
   -- effect:play(playerObject)    
end

function onTalk(e)
    stopWorld()
    local actor = e.data
    --actor:getProperty('actor_id')
    local id = tonumber(2) 
    
    talkView = TalkView {
        actor = repositry:getActorById(id),
        talk = repositry:getTalkById(1),
        scene = scene,        
    }           
    talkView:addEventListener("close", talkView_onClose)
end

function talkView_onClose(e)
    startWorld()
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
    --flower.openScene(scenes.MENU, {animation = "overlay"})
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
    --rpgMap:updateRenderOrder()
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

