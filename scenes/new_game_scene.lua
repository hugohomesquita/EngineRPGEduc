----------------------------------------------------------------------------------------------------
-- Módulo de cena que mostra a cena new_game
--
----------------------------------------------------------------------------------------------------

module(..., package.seeall)

-- imports
local entities = require "libs/entities"
local repositry = entities.repositry
local entityPool = entities.entityPool
local NewGameView = views.NewGameView

-- variables
local newGameView
local PLAYER_ID

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)    
    newGameView = NewGameView {
        scene = scene,        
    }
    
    newGameView:addEventListener("initGame", onInitGame)
    newGameView:addEventListener("back", onBack)    
end

function onInitGame(e)
    createNewPlayer(e.data)    
    flower.gotoScene(scenes.LOADING, {
        PLAYER_ID = PLAYER_ID, 
        animation = "fade",
        nextSceneName = scenes.MAP,
        nextSceneParams = {animation = "fade"},
    })
end

function onBack(e)
    flower.gotoScene(scenes.LOADING, {
        animation = "fade",
        nextSceneName = scenes.TITLE,
        nextSceneParams = {animation = "fade"},
    })
end

function createNewPlayer(player)
    assert(player.name)
    assert(player.gender)
    
    local playerData = {}    
    playerData.name= player.name
    playerData.gender = player.gender   
    PLAYER_ID = repositry:createPlayer(playerData)
    assert(PLAYER_ID)    
end



