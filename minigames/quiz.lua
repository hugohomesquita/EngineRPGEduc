module(..., package.seeall)
--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local views = require('minigames/libs/views')
local QuizQuestionView = views.QuizQuestionView

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    local questoes = dofile('minigames/data/questoes.lua')    
    
    talkView = QuizQuestionView {        
        scene = scene,        
    }
end

function onClose(e)
      
end
