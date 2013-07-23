module(..., package.seeall)


local TalkView = views.TalkView

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)    
    
    talkView = TalkView {
        actorA = e.data.actorA,
        actorB = e.data.actorB,
        scene = scene,        
    }
    
   -- menuControlView = MenuControlView {
    --    scene = scene,
    --}
    --menuControlView:addEventListener("back", menuControlView_OnBack)
end

function menuControlView_OnBack(e)    
    flower.closeScene()
end