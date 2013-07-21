module(..., package.seeall)

--------------------------------------------------------------------------------
-- import
--------------------------------------------------------------------------------
local MenuControlView = views.MenuControlView
local ProfileView = views.ProfileView

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    ProfileView = ProfileView {
        scene = scene,
    }
    
    --menuControlView = MenuControlView {
    --    scene = scene,
    --}
    
    -- event listeners
    --menuControlView:addEventListener("back", menuControlView_OnBack)
    ProfileView:addEventListener("back", onBack)
end

function menuMainView_OnEnter(e)
    --print("")
end

function onBack(e)
    flower.closeScene()
end
