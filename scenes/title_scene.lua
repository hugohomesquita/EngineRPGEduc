----------------------------------------------------------------------------------------------------
-- タイトルを表示するシーンモジュールです.
--
----------------------------------------------------------------------------------------------------

module(..., package.seeall)

-- import
local Image = flower.Image
local UIView = widget.UIView
local Button = widget.Button
local TitleMenuView = views.TitleMenuView

-- variables
local titleMenuView

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)    
    titleMenuView = TitleMenuView {
        scene = scene,        
    }
    
    titleMenuView:addEventListener("newGame", onNewGame)
    titleMenuView:addEventListener("loadGame", onLoadGame)
    
end

function onNewGame(e)
    flower.gotoScene(scenes.LOADING, {
        animation = "fade",
        nextSceneName = scenes.NEW_GAME,
        nextSceneParams = {animation = "fade"},
    })
end

function onLoadGame(e)
    flower.gotoScene(scenes.LOADING, {
        animation = "fade",
        nextSceneName = scenes.LOAD_GAME,
        nextSceneParams = {animation = "fade"},
    })
end
