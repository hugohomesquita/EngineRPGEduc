module(..., package.seeall)
--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local Panel = widget.Panel

local views = require('minigames/libs/views')

local QuizQuestionView = views.QuizQuestionView
local MenuPrincipalView = views.MenuPrincipalView
local LojaView = views.LojaView


local entities = require "libs/entities"
local repositry = entities.repositry

Resources.addResourceDirectory("assets/fonts")
--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

function onCreate(e)
    flower.Runtime:addEventListener("resize", onResize)
    local actor = repositry:getPlayer()
    
    view = widget.UIView {
        scene = scene
    } 
    
    -- BACKGROUND
    mainBackground = Panel {
        size = {scene:getWidth(),scene:getHeight()},
        pos = {0, 0},
        backgroundTexture = "minigames/assets/bg_main.png",        
        parent = view,        
    }
    
    menuPrincipal = MenuPrincipalView {
        scene = scene
    }
    menuPrincipal:addEventListener("loja", onLoja)
    
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

function onLoja(e)
    flower.openScene("minigames/scenes/loja_scene")
end


function onCloseResult(e)
    quiz:nextQuestion()
end

function onSelectAnswer(e)
    if e.data.target.correct then
        flower.openScene("minigames/scenes/result_question_scene")       
    else
        
    end
end

function onStopQuiz(e)
end

function onJumpQuestion(e)
end

function onFinnishQuestions(e)
    
end  


function onClose(e)
      
end
