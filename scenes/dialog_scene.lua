module(..., package.seeall)


local TalkView = views.TalkView

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)    
    
    --[[talkView = TalkView {
        actor = e.data.actor,
        talk = e.data.talk,
        scene = scene,        
    }  
    talkView:addEventListener("back", talkView_OnBack)]]
end

function talkView_OnBack(e)       
    flower.closeScene(e.data)
end