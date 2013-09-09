module(..., package.seeall)

--------------------------------------------------------------------------------
-- import
--------------------------------------------------------------------------------
local MenuControlView = views.MenuControlView
local ProfileView = views.ProfileView

local entities = require "libs/entities"
local repositry = entities.repositry
--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    ProfileView = ProfileView {
        scene = scene,   
        actor = repositry:getPlayerById(1)
    }     
    ProfileView:addEventListener("back", onBack)
end

function menuMainView_OnEnter(e)
    --print("")
end

function onBack(e)
    flower.closeScene()
end
