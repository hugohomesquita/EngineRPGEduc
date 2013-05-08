module(..., package.seeall)

--------------------------------------------------------------------------------
-- Classes
--------------------------------------------------------------------------------
local CustomScene = flower.class(flower.Scene)

local EVENT_CLOSE_MINIGAME = "onClose"


questions = {
    {
      answer = "DOIS MINUTOS SOMADOS A TRÊS GRAUS RESULTA EM:",
      a1 = {value = "180",correct=false},
      a2 = {value = "182",correct=true},
      a3 = {value = "184",correct=false},
      a4 = {value = "186",correct=false},      
    },
    {
      answer = "QUESTÃO 2",
      a1 = {value = "10",correct=false},
      a2 = {value = "12",correct=false},
      a3 = {value = "14",correct=true},
      a4 = {value = "16",correct=false},       
    },
    {
      answer = "QUESTÃO 3",
      a1 = {value = "18",correct=false},
      a2 = {value = "1",correct=false},
      a3 = {value = "18",correct=false},
      a4 = {value = "15",correct=true}, 
    },
  } 


function CustomScene:createController(params)
    local controller = {}
    
    function controller.onCreate(e)
        local scene = e.target
        
        layer = flower.Layer()
        layer:setScene(scene)
        layer:setTouchEnabled(true)

        wMax,hMax = scene:getWidth()-80,scene:getHeight()-80
        

        local group = flower.Group(layer,wMax,hMax)
        group:setPos(40,40)
        
        local rect = flower.Rect(group:getWidth(), group:getHeight())
        rect:setColor(0, 0, 0.5, 1)
    
        local label = flower.Label("Quiz",wMax,hMax)
        label:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
        label:addEventListener("touchDown", controller.onTouchDown)
    
        group:addChild(rect)
        group:addChild(label)
        display_question()               
    end
    INDEX_QUESTION = 1
    POINTS = 0
    function display_question()
      --print(#questions)
      --[[for i,question in ipairs(questions) do
        print(question.answer)
        print(question.a1.value)
        --print(question.correct)
      end]]      
      local group = flower.Group(layer,wMax,hMax)
      group:setPos(40,90)
        
        
      question = questions[INDEX_QUESTION]  
      local lbQuestion = flower.Label(question.answer,wMax,hMax)
      lbQuestion:setAlignment(MOAITextBox.LEFT_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)      
      group:addChild(lbQuestion)
      
      a1 = widget.Button()
      a1:setSize(200, 50)
      a1:setPivToCenter()
      a1:setPos(group:getWidth()/2 - 100, 50)
      a1:setText(question.a1.value)
      a1:setTextSize(24)
      a1:setParent(group)
      a1:setOnClick(button_OnClick)
      a1.data = question.a1.correct
      
      a2 = widget.Button()
      a2:setSize(200, 50)
      a2:setPivToCenter()
      a2:setPos(group:getWidth()/2 - 100, a1:getBottom()+50)
      a2:setText(question.a2.value)
      a2:setTextSize(24)
      a2:setParent(group)
      a2:setOnClick(button_OnClick)
      a2.data = question.a2.correct 
       
      a3 = widget.Button()
      a3:setSize(200, 50)
      a3:setPivToCenter()
      a3:setPos(group:getWidth()/2 - 100, a2:getBottom()+50)
      a3:setText(question.a3.value)
      a3:setTextSize(24)
      a3:setParent(group)
      a3:setOnClick(button_OnClick)
      a3.data = question.a3.correct
      
      a4 = widget.Button()
      a4:setSize(200, 50)
      a4:setPivToCenter()
      a4:setPos(group:getWidth()/2 - 100, a3:getBottom()+50)
      a4:setText(question.a4.value)
      a4:setTextSize(24)
      a4:setParent(group)
      a4:setOnClick(button_OnClick)
      a4.data = question.a4.correct
      
    end
    
    
    function display_result()
      layer:clear()
      
      local group = flower.Group(layer,wMax,hMax)
      group:setPos(40,40)
      
      local rect = flower.Rect(group:getWidth(), group:getHeight())
      rect:setColor(0, 0, 0.5, 1)
  
      local label = flower.Label("Você ganhou "..tostring(POINTS).." XP",wMax,hMax)
      label:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
      label:addEventListener("touchDown", controller.onTouchDown)
      
      group:addChild(rect)      
      group:addChild(label)
      
      local buttonBack = widget.Button()
      buttonBack:setSize(200, 50)
      buttonBack:setPivToCenter()
      buttonBack:setPos(group:getWidth()/2 - 100, group:getHeight()/2+50)
      buttonBack:setText("VOLTAR")
      buttonBack:setTextSize(24)
      buttonBack:setParent(group)
      buttonBack:setOnClick(buttonBack_OnClick)
  
      --group:addChild(buttonBack)
      
    end
    
    function buttonBack_OnClick(e)
      
      --flower.closeScene({animation = "popOut", backScene = "scenes/game_scene"})
      object ={
        XP = POINTS
      }
      self:dispatchEvent(EVENT_CLOSE_MINIGAME, object)
      flower.closeScene(self)      
    end
    
    
    function button_OnClick(e)
      if e.target.data then
          POINTS = POINTS + 50
      end
      display_result()
    end
    
    
    function controller.onOpen(e)
        local data = e.data
        data.animation = "popIn"
    end
    
    function controller.onTouchDown(e)
        --flower.openScene("ChildScene", {sceneFactory = flower.ClassFactory(ChildScene)})
        --flower.closeScene(self)
    end
    
    function controller.onClose(e)
      
    end
    
    return controller
end

return CustomScene