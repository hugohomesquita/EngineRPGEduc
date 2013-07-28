module(..., package.seeall)
--------------------------------------------------------------------------------
-- Imports
--------------------------------------------------------------------------------

local views = require('minigames/libs/views')
local localRepository = require('minigames/libs/repository')
local AvatarInfoBox = widgets.AvatarInfoBox
local QuizData = localRepository.QuizData
local QuizQuestionView = views.QuizQuestionView


local closeScene = false
local result = nil

--------------------------------------------------------------------------------
-- Event Handler Scene
--------------------------------------------------------------------------------

function onCreate(e)  
    local w,h = flower.getViewSize()
    player = e.data.player    
    
    local dataMiniGame = QuizData()    
    playerData = dataMiniGame:getDataByPlayerId(player.id)
        
    questionsData = dofile('minigames/data/questoes.lua')
    totalQuestions = #questionsData
    questionNumber = 1    
    
    quizQuestionView = QuizQuestionView {
        size = {w-100,h-100},
        scene = scene,
        playerData = playerData,                
    }
    quizQuestionView:setQuestionsData(questionsData)    
    playerInfo = AvatarInfoBox {        
        scene = scene,
        player = player
    }     
    
    quizQuestionView:addEventListener('selectAnswer', quizQuestionView_onSelectAnswer)        
    quizQuestionView:addEventListener('finnishQuestions', quizQuestionView_onFinish)
    quizQuestionView:addEventListener('pular', quizQuestionView_onPular)
    quizQuestionView:addEventListener('verResposta', quizQuestionView_onVerResposta)
    quizQuestionView:nextQuestion()
    
end

function onUpdate(e)    
    if closeScene then
        flower.closeScene()
    end
    quizQuestionView:updateDisplay()
end

function onClose(e)
    scene:dispatchEvent("closeQuiz", result)
end 
 
--------------------------------------------------------------------------------
-- Event Handler Views
--------------------------------------------------------------------------------
 
function quizQuestionView_onSelectAnswer(e)
    if e.data.target.correct then
        if quizQuestionView:nextQuestion() then
          questionNumber = questionNumber + 1
          sceneResult = flower.openScene("minigames/scenes/message_view_scene",
            {animation="overlay", message="PERGUNTA Nº ".. tostring(questionNumber) .." de ".. tostring(totalQuestions) ..""})          
        end
    else
        sceneResult = flower.openScene("minigames/scenes/message_view_scene",{animation="overlay", message="VOCÊ ERROU!"})
        closeScene = true     
    end
end

function quizQuestionView_onFinish(e)
    flower.openScene("minigames/scenes/message_view_scene",{animation="overlay", message="PARABÉNS VOCÊ CONSEGUIU!"})
    closeScene = true
    result = true
end

function quizQuestionView_onPular(e)
    if playerData.pular >= 1 then
      playerData.pular = playerData.pular - 1
      quizQuestionView:nextQuestion()
    else
      flower.openScene("minigames/scenes/message_view_scene",{animation="overlay", message="VOCÊ NÃO TEM MAIS PULOS"})
    end
end

function quizQuestionView_onVerResposta(e)
    
end

