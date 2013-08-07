----------------------------------------------------------------------------------------------------
-- タイトルを表示するシーンモジュールです.
--
----------------------------------------------------------------------------------------------------

module(..., package.seeall)

-- import
local Image = flower.Image
local UIView = widget.UIView
local Button = widget.Button
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
    
    --titleMenuView:addEventListener("newGame", onNewGame)
    --titleMenuView:addEventListener("loadGame", onLoadGame)
    
end

function onNewGame(e)
    flower.gotoScene(scenes.LOADING, {
        animation = "fade",
        nextSceneName = scenes.MAP,
        nextSceneParams = {animation = "fade"},
    })
end

function onLoadGame(e)
    
end
