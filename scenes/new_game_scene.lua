----------------------------------------------------------------------------------------------------
-- Módulo de cena que mostra a cena new_game
--
----------------------------------------------------------------------------------------------------

module(..., package.seeall)

-- imports
local NewGameView = views.NewGameView

-- variables
local newGameView

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
    flower.gotoScene(scenes.LOADING, {
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
