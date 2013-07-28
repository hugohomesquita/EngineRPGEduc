module(..., package.seeall)
--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local Panel = widget.Panel

local views = require('minigames/libs/views')

local QuizQuestionView = views.QuizQuestionView
local MenuPrincipalView = views.MenuPrincipalView
local LojaView = views.LojaView
local AvatarInfoBox = widgets.AvatarInfoBox

local entities = require "libs/entities"
local repositry = entities.repositry
local entityPool = entities.entityPool

Resources.addResourceDirectory("assets/fonts")
--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    flower.Runtime:addEventListener("resize", onResize)
    
    player = repositry:getPlayerById(1)
        
    local w,h = flower.getViewSize()    

    view = widget.UIView {
        scene = scene
    }     
    
    menuPrincipal = MenuPrincipalView {
        size = {w-100,h-100},
        scene = scene
    }
    menuPrincipal:addEventListener("comecar", menuPrincipal_onComecar) 
    menuPrincipal:addEventListener("loja", onLoja)
    menuPrincipal:addEventListener("close", menuPrincipal_onClose)
    
    
    playerInfo = AvatarInfoBox {        
        scene = scene,
        player = player
    }
   
    
    --loja = LojaView {
     --   scene = scene
    --}    
   --[[ quiz = QuizQuestionView {
        player = actor,
        scene = scene,        
    }               
    quiz:addEventListener("stop",onStopQuiz)
    quiz:addEventListener("jump",onJumpQuestion)
    quiz:addEventListener("finnishQuestions",onFinnishQuestions)
    quiz:addEventListener("closeResult",onCloseResult)]]
end

function onResize(e)
   local w,h = flower.getViewSize()
   scene:setSize(w,h)
   
   mainBackground:setSize(w,h)
  -- menuPrincipal:setSize(w,h)
end

function menuPrincipal_onComecar(e)
    local quiz = flower.openScene("minigames/scenes/question_scene",{player = player})    
end

function menuPrincipal_onClose(e)
    flower.closeScene()
end

function onLoja(e)
    local loja = flower.openScene("minigames/scenes/loja_scene",{player = player})
    loja:addEventListener("onClose",onCloseLoja)
end

function onCloseLoja()
    playerInfo:updateDisplay()
    repositry:savePlayer(1)
end


function onCloseResult(e)
    quiz:nextQuestion()
end


function onStopQuiz(e)
end

function onJumpQuestion(e)
end

function onFinnishQuestions(e)
    
end  


function onClose(e)
      
end
