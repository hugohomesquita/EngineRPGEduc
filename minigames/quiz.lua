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

local closeScene = false
local result = nil
--------------------------------------------------------------------------------
-- Event Handler Scene
--------------------------------------------------------------------------------

function onCreate(e)
    flower.Runtime:addEventListener("resize", onResize)
    
    player = repositry:getPlayerById(1)
        
    local w,h = flower.getViewSize()    
    
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
   
end

function onResize(e)
   local w,h = flower.getViewSize()
   scene:setSize(w,h)
   
   mainBackground:setSize(w,h)  
end

function onUpdate()
    if closeScene then
        local var = true
        flower.closeScene()
    end
end

function onClose(e)
    scene:dispatchEvent("closeMinigame", result)
end


--------------------------------------------------------------------------------
-- Event Handler Views
--------------------------------------------------------------------------------

--
--  MENU DO QUIZ
--
function menuPrincipal_onComecar(e)
    local quiz = flower.openScene("minigames/scenes/question_scene",{player = player})    
    quiz:addEventListener("closeQuiz", quiz_onClose)
end

function menuPrincipal_onClose(e)
    closeScene = true
end

function quiz_onClose(e)  
    result = e.data          
    closeScene = true
end

--
--  MENU DA LOJA
--
function onLoja(e)
    local loja = flower.openScene("minigames/scenes/loja_scene",{player = player})
    loja:addEventListener("close", onCloseLoja)
end

function onCloseLoja()
    playerInfo:updateDisplay()    
end


