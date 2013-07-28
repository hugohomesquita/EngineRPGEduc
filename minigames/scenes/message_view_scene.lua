module(..., package.seeall)
--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local views = require('minigames/libs/views')
local MessageView = views.MessageView
--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)    
    local messageView = MessageView{
        scene = scene,
        message = e.data.message,
        typeView = e.data.typeView,
        question = e.data.question        
    }    
    messageView:addEventListener('close',messageView_onClose)
    messageView:addEventListener('sim',messageView_onSim)
    messageView:addEventListener('nao',messageView_onNao)
end

function onOpen(e)
    local data = e.data
    data.animation = "popIn"
end

function messageView_onSim(e)
    scene:dispatchEvent("sim")
    flower.closeScene({animation="popOut"})
end

function messageView_onNao(e)
    scene:dispatchEvent("nao")
    flower.closeScene({animation="popOut"})
end

function messageView_onClose(e)    
    flower.closeScene({animation="popOut"})
end

