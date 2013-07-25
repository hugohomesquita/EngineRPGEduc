module(..., package.seeall)
--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local views = require('minigames/libs/views')
local ResultQuestionView = views.ResultQuestionView
--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    resultQuestionView = ResultQuestionView{
        scene = scene,        
    }    
    resultQuestionView:addEventListener('close',resultQuestionView_onClose)
end

function resultQuestionView_onClose(e)
    flower.closeScene()
end

function onClose(e)
      
end
