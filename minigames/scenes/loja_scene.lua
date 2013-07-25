module(..., package.seeall)
--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local views = require('minigames/libs/views')
local LojaView = views.LojaView

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    view = widget.UIView {
        scene = scene
    }        
    local mainBackground = widget.Panel {
        size = {scene:getWidth(),scene:getHeight()},
        pos = {0, 0},
        backgroundTexture = "minigames/assets/bg_main.png",        
        parent = view,        
    }
    
    lojaView = LojaView{
        scene = scene,        
    }    
    --resultQuestionView:addEventListener('close',resultQuestionView_onClose)
end

function resultQuestionView_onClose(e)
    --flower.closeScene()
end

function onClose(e)
      
end
