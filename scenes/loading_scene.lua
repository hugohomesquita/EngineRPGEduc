----------------------------------------------------------------------------------------------------
-- シーン間のロードを行う為のシーンモジュールです.
-- シーンの読み込みが長かったり、同一シーンに遷移する場合に使用します.
----------------------------------------------------------------------------------------------------
module(..., package.seeall)

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    
end

function onStart(e)
    local data = e.data
    local nextSceneName = data.nextSceneName
    local nextSceneParams = data.nextSceneParams
    nextSceneParams.PLAYER_ID = data.PLAYER_ID
    nextSceneParams.MAP = data.MAP
    nextSceneParams.hotSpot = data.hotSpot
    flower.gotoScene(nextSceneName, nextSceneParams)    
end