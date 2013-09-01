----------------------------------------------------------------------------------------------------
-- Módulo de cena que mostra a cena new_game
--
----------------------------------------------------------------------------------------------------

module(..., package.seeall)

-- imports
local entities = require "libs/entities"
local repositry = entities.repositry
local entityPool = entities.entityPool
local LoadGameView = views.LoadGameView

-- variables
local loadGameView
local PLAYER_ID
local LIST_PLAYERS
--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)    
    LIST_PLAYERS = assert(repositry.getPlayers())    
    loadGameView = LoadGameView {
        scene = scene,
        players = LIST_PLAYERS
    }
    
    loadGameView:addEventListener("initGame", onInitGame)
    loadGameView:addEventListener("back", onBack)    
end

function onInitGame(e)        
    PLAYER_ID = e.data.target.player.id
    assert(PLAYER_ID)
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




