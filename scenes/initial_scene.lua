----------------------------------------------------------------------------------------------------
-- ゲーム起動時にリソースを初期化するためのシーンモジュールです.
--
----------------------------------------------------------------------------------------------------
module(..., package.seeall)

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    
end

function onStart(e)
    --preloadFontTextures()
    
    flower.gotoScene(scenes.NEW_GAME)
end


function preloadFontTextures()
    --local font1 = flower.getFont("VL-PGothic.ttf", nil, 18)
    --local font2 = flower.getFont("VL-PGothic.ttf", nil, 20)
end