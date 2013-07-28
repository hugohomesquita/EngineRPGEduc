-- module
local M = {}

-- import
local flower = require "hanappe/flower"
local widget = require "hanappe/extensions/widget"
local class = flower.class
local table = flower.table

local Label = flower.Label
local Panel = widget.Panel
local Event = flower.Event


local InputMgr = flower.InputMgr


local Image = flower.Image
local ImageButton = widget.ImageButton
local NineImage = flower.NineImage
local UIView = widget.UIView
local Joystick = widget.Joystick
local Button = widget.Button

local ListBox = widget.ListBox
local ListItem = widget.ListItem
local TextBox = widget.TextBox

-- classes
local QuizQuestionView
local MessageView
--------------------------------------------------------------------------------
-- @type QuizQuestionView
-- 
--------------------------------------------------------------------------------
QuizQuestionView = class(UIView)
M.QuizQuestionView = QuizQuestionView

---
-- 
function QuizQuestionView:_createChildren()
    QuizQuestionView.__super._createChildren(self)       
    
    local font = flower.getFont("minigames/assets/fonts/SHOWG.TTF", nil, 18)  
    -- BACKGROUND
    self._mainBackground = Panel {
        size = {self:getWidth(),self:getHeight()},
        pos = {0, 0},
        backgroundTexture = "minigames/assets/bg_main2.png",        
        parent = self,        
    }    
        
    self._mainQuestionPanel = Panel {               
        backgroundTexture = "minigames/assets/bg_msg.png",
        parent = self
    }       
    
    self.mainQuestion = Label("",nil,nil, font, 18)    
    self:addChild(self.mainQuestion)
    
    self.answerA = Button {
        text = "",        
        textColor = {1,1,1,1},
        fontName = font,     
        normalTexture = "minigames/assets/button-normal.png",
        selectedTexture = "minigames/assets/button-selected.png",
        onClick = function(e)
            self:dispatchEvent("selectAnswer", e)
        end,
        parent = self
    }
    self.answerB = Button {
        text = "",        
        textColor = {1,1,1,1},
        fontName = font,     
        normalTexture = "minigames/assets/button-normal.png",
        selectedTexture = "minigames/assets/button-selected.png",
        onClick = function(e)
            self:dispatchEvent("selectAnswer", e)
        end,
        parent = self
    }
    self.answerC = Button {
        text = "",        
        textColor = {1,1,1,1},
        fontName = font,     
        normalTexture = "minigames/assets/button-normal.png",
        selectedTexture = "minigames/assets/button-selected.png",
        onClick = function(e)
            self:dispatchEvent("selectAnswer", e)
        end,
        parent = self
    }
    self.answerD = Button {
        text = "",
        textColor = {1,1,1,1},
        fontName = font,     
        normalTexture = "minigames/assets/button-normal.png",
        selectedTexture = "minigames/assets/button-selected.png",
        onClick = function(e)
            self:dispatchEvent("selectAnswer", e)
        end,
        parent = self
    }
    
    self._helpPanel = Panel {               
        backgroundTexture = "minigames/assets/bg_msg.png",
        parent = self
    }  
    
    self.ajuda = Label("AJUDA", nil, nil, font, 30)            
    self:addChild(self.ajuda)
    
    self.pular = Button {      
      text = "0x PULAR",            
      textColor = {1,1,1,1},
      fontName = font,      
      normalTexture = "minigames/assets/button-normal.png",
      selectedTexture = "minigames/assets/button-selected.png",
      onClick = function(e)
          self:dispatchEvent("pular", e)
      end,              
      parent = self
    }  
    
   
    self.verResposta = Button {      
      text = "0x VER RESPOSTA",            
      textColor = {1,1,1,1},
      fontName = font,      
      normalTexture = "minigames/assets/button-normal.png",
      selectedTexture = "minigames/assets/button-selected.png",
      onClick = function(e)
          self:dispatchEvent("verResposta", e)
      end,              
      parent = self
    } 
       
    
    self.listQuestionsDisplayed = {}  
    self.totalQuestions = 0
    
    self.questions = {}    
end

function QuizQuestionView:updateDisplay()
    QuizQuestionView.__super.updateDisplay(self)       
    local xOffset,yOffset = 50,50
    
    
    self._mainBackground:setSize(self:getWidth(),self:getHeight())
    self._mainBackground:setPos(xOffset,yOffset)                 
    
    --D
    self.answerD:setSize(self._mainBackground:getWidth() / 2, 40)
    self.answerD:setPos(self._mainBackground:getLeft(),self._mainBackground:getBottom() - 45)
    --C
    self.answerC:setSize(self.answerD:getWidth(), 40)
    self.answerC:setPos(self.answerD:getLeft(), self.answerD:getTop() - self.answerC:getHeight() - 5)
    --B
    self.answerB:setSize(self.answerD:getWidth(), 40)
    self.answerB:setPos(self.answerD:getLeft(), self.answerC:getTop() - self.answerB:getHeight() - 5)
    --A
    self.answerA:setSize(self.answerD:getWidth(), 40)
    self.answerA:setPos(self.answerD:getLeft(), self.answerB:getTop() - self.answerA:getHeight() - 5)
    
    self._mainQuestionPanel:setSize(self._mainBackground:getWidth()/2 + 50, self:getHeight() / 4)
    self._mainQuestionPanel:setPos(self.answerD:getLeft(),self.answerA:getTop() - self._mainQuestionPanel:getHeight() - 10)
    
    --QUESTION VIEW
    self.mainQuestion:setSize(self._mainBackground:getWidth()/2 + 40, self:getHeight() / 4)    
    self.mainQuestion:setPos(self._mainQuestionPanel:getLeft() + 10, self._mainQuestionPanel:getTop() + 10)   
    
    -- HELP BOX
    self._helpPanel:setSize(200,95)
    self._helpPanel:setPos(self._mainBackground:getRight() - self._helpPanel:getWidth(), self.answerA:getTop())
    
    self.ajuda:setPos(self._helpPanel:getLeft() + (self.ajuda:getWidth()/2), self._helpPanel:getTop() - self.ajuda:getHeight())
    --PULO        
    self.pular:setSize(self._helpPanel:getWidth()-10, 40)
    self.pular:setPos(self._helpPanel:getLeft() + 5, self._helpPanel:getTop() + 5)
    local pular = string.format("%dX PULAR", self._playerData.pular)
    self.pular:setText(pular)
    --RESPOSTA    
    self.verResposta:setSize(self._helpPanel:getWidth()-10, 40)
    self.verResposta:setPos(self._helpPanel:getLeft() + 5, self.pular:getBottom() + 5)
    local verResposta = string.format("%dX VER RESPOSTA", self._playerData.verResposta)
    self.verResposta:setText(verResposta)   
    
end

function QuizQuestionView:nextQuestion()
    local idQuestion = 0
            
    if #self.listQuestionsDisplayed == self.totalQuestions then
        self:dispatchEvent("finnishQuestions")
        return
    end
        
    local ok = true
    while ok do
        idQuestion = math.random(self.totalQuestions) 
        
        if not table.keyOf(self.listQuestionsDisplayed, idQuestion) then
           ok = false
        end                        
    end
    
    
    table.insertElement(self.listQuestionsDisplayed,idQuestion)          
    
    self.mainQuestion:setString(self.questions[idQuestion].answer)
    self.answerA:setText(self.questions[idQuestion].a1.value)
    self.answerA.correct = self.questions[idQuestion].a1.correct
    
    self.answerB:setText(self.questions[idQuestion].a2.value)
    self.answerB.correct = self.questions[idQuestion].a2.correct
    
    self.answerC:setText(self.questions[idQuestion].a3.value)
    self.answerC.correct = self.questions[idQuestion].a3.correct
    
    self.answerD:setText(self.questions[idQuestion].a4.value)
    self.answerD.correct = self.questions[idQuestion].a4.correct
           
end

function QuizQuestionView:setPlayerData(playerData)
    self._playerData = playerData
end

function QuizQuestionView:setQuestionsData(questionsData)
    self.questions = questionsData    
    self.totalQuestions = #self.questions     
end

--------------------------------------------------------------------------------
-- @type QuizQuestionView
-- 
--------------------------------------------------------------------------------
MessageView = class(UIView)
M.MessageView = MessageView

---
-- コンストラクタ
-- @param params パラメータ
function MessageView:init(params)    
    MessageView.__super.init(self, params)
end

---
-- 子オブジェクトを生成します.
function MessageView:_createChildren()    
    MessageView.__super._createChildren(self)   
    
    local font = flower.getFont("minigames/assets/fonts/SHOWG.TTF", nil, 18)  
    
    self._bg = Panel {
        size = {self:getWidth(), self:getHeight()},
        pos = {0, 0},
        backgroundTexture = "minigames/assets/bg_msg.png",
        parent = self
    } 
    self._bg:setColor(0,0,0,0.4)
    
    self.mainPanel = Panel {
        size = {self:getWidth() / 2, self:getHeight() / 2},
        pos = {50, 50},
        backgroundTexture = "minigames/assets/bg_msg.png",
        parent = self
    }               
    
    self.msg = Label("MENSAGEM", nil, nil, font, 30)            
    self:addChild(self.msg)
    
    
    self._yes = Button {      
      text = "SIM",      
      textSize = 30,
      textColor = {1,1,1,1},
      fontName = font,      
      normalTexture = "minigames/assets/button-normal.png",
      selectedTexture = "minigames/assets/button-selected.png",
      onClick = function(e)
          self:dispatchEvent("sim", e)
      end,              
      parent = self
    }  
    self._yes:setVisible(false)
    
    self._no = Button {      
      text = "Não",      
      textSize = 30,
      textColor = {1,1,1,1},
      fontName = font,      
      normalTexture = "minigames/assets/button-normal.png",
      selectedTexture = "minigames/assets/button-selected.png",
      onClick = function(e)
          self:dispatchEvent("nao", e)
      end,              
      parent = self
    }  
    self._no:setVisible(false)
    
    self.question = Label("QUESTION", nil, nil, font, 20)            
    self.question:setVisible(false)
    self:addChild(self.question)
end

function MessageView:onTouchDown(e)
    self:dispatchEvent("close")
end

function MessageView:updateDisplay()
    MessageView.__super.updateDisplay(self)    
        
    self.mainPanel:setSize(self:getWidth() / 2, self:getHeight() / 2)
    self.mainPanel:setPos(self:getWidth() / 2 - self.mainPanel:getWidth()/2, self:getHeight() / 2 - self.mainPanel:getHeight()/2)
    
    --self.msg:setSize(self.mainPanel:getWidth(),40)
    
    self.msg:setPos(self.mainPanel:getWidth()/2 , self.mainPanel:getHeight() - self.msg:getHeight()/2)
    self.msg:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
            
    if self._type == "yesno" then                  
      
        self.msg:setSize(self.mainPanel:getWidth(),40)
        self.msg:setPos(self.mainPanel:getWidth()/2 , self.mainPanel:getTop()+50)
        self.msg:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
      
        self.question:setPos(self.mainPanel:getWidth()/2, self.msg:getBottom() + 50)
        self.question:setString(self._question)
        self.question:setSize(self.mainPanel:getWidth(),80)
        self.question:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
        self.question:setVisible(true)
      
        self._yes:setSize(self.mainPanel:getWidth()/2-20, 50)
        self._yes:setPos(self.mainPanel:getLeft() + 5,self.mainPanel:getBottom() - self._yes:getHeight() - 5)
        self._yes:setVisible(true)
        
        self._no:setSize(self.mainPanel:getWidth()/2-20, 50)
        self._no:setPos(self.mainPanel:getRight() - self._no:getWidth() - 5,self.mainPanel:getBottom() - self._yes:getHeight() - 5)
        self._no:setVisible(true)
    else
        self:addEventListener(Event.TOUCH_DOWN, self.onTouchDown, self)
    end
end

function MessageView:setMessage(msg)
    self.msg:setString(msg)
    self.msg:fitSize(#msg)
end

function MessageView:setTypeView(typeView)
    self._type = typeView
end

function MessageView:setQuestion(question)
    self._question = question
end

--------------------------------------------------------------------------------
-- @type MenuPrincipalView
-- 
--------------------------------------------------------------------------------
MenuPrincipalView = class(UIView)
M.MenuPrincipalView = MenuPrincipalView


function MenuPrincipalView:init(params)    
    MenuPrincipalView.__super.init(self, params)
end

function MenuPrincipalView:_createChildren()    
    MenuPrincipalView.__super._createChildren(self)    
    
    local font = flower.getFont("minigames/assets/fonts/SHOWG.TTF", nil, 18)    
    
    -- BACKGROUND
    self._mainBackground = Panel {
        size = {self:getWidth(),self:getHeight()},
        pos = {0, 0},
        backgroundTexture = "minigames/assets/bg_main.png",        
        parent = self,        
    }
    
    self._menuPrincipalLabel = Label("MENU PRINCIPAL", nil, nil, font, 20)            
    self:addChild(self._menuPrincipalLabel)
           
    self._btComecar = Button {      
      text = "COMEÇAR",      
      textSize = 30,
      fontName = font,      
      normalTexture = "minigames/assets/button-normal.png",
      selectedTexture = "minigames/assets/button-selected.png",
      onClick = function(e)
          self:dispatchEvent("comecar", e)
      end,      
      
      parent = self
    }        
    self._btComecar:setTextColor(1,1,1,1)    
    self:addChild(self._btComecar)
    
    self._btLoja = Button {      
      text = "LOJA",  
      textSize = 30,
      fontName = font,      
      normalTexture = "minigames/assets/button-normal.png",
      selectedTexture = "minigames/assets/button-selected.png",
      onClick = function(e)
          self:dispatchEvent("loja", e)
      end,      
      parent = self
    }        
    self._btLoja:setTextColor(1,1,1,1)    
    self:addChild(self._btLoja)
    
    self._closeButton = ImageButton {                        
      normalTexture = "minigames/assets/exit.png",
      selectedTexture = "minigames/assets/exitHover.png",      
      onClick = function(e)
          self:dispatchEvent("close", e)
      end,      
      parent = self
    }              
    self:addChild(self._closeButton)
    
end

function MenuPrincipalView:updateDisplay()
    MenuPrincipalView.__super.updateDisplay(self)  
    local xOffset,yOffset = 50,50
    self._mainBackground:setSize(self:getWidth(),self:getHeight())
    self._mainBackground:setPos(xOffset,yOffset)
    
    self._menuPrincipalLabel:setPos(self:getWidth() / 2 - self._menuPrincipalLabel:getWidth() / 2 + xOffset, 
      self:getHeight() / 2 - self._menuPrincipalLabel:getHeight() / 2 + yOffset)    
    
    local x = self._mainBackground:getWidth() / 2 - self._mainBackground:getWidth() / 4 + xOffset   
    self._btComecar:setPos(x, self._menuPrincipalLabel:getBottom() + 15)
    self._btComecar:setSize(self._mainBackground:getWidth() / 2, self._mainBackground:getHeight() / 7)
    
    self._btLoja:setPos(x, self._btComecar:getBottom() + 15)
    self._btLoja:setSize(self._mainBackground:getWidth() / 2, self._mainBackground:getHeight() / 7)
    
    
    self._closeButton:setPos(self._mainBackground:getLeft(), self._mainBackground:getBottom() - self._closeButton:getHeight())
end

--------------------------------------------------------------------------------
-- @type LojaView
-- 
--------------------------------------------------------------------------------
LojaView = class(UIView)
M.LojaView = LojaView


function LojaView:init(params)    
    LojaView.__super.init(self, params)
end

function LojaView:_createChildren()    
    LojaView.__super._createChildren(self)   
    local font = flower.getFont("minigames/assets/fonts/SHOWG.TTF", nil, 18)    
    
    -- BACKGROUND
    self._mainBackground = Panel {
        size = {self:getWidth(),self:getHeight()},
        pos = {0, 0},
        backgroundTexture = "minigames/assets/bg_main.png",        
        parent = self,        
    }    
       
    self._meusItensLabel = Label("MEUS ITENS", nil, nil, font, 20)        
    self:addChild(self._meusItensLabel)
    
    self._pularContemPanel = Panel {      
      backgroundTexture = "minigames/assets/panel.png",                
      parent = self,            
    }       
    
    self._pularContemLabel = Label("0X PULAR", nil, nil, font, 30)        
    self._pularContemLabel:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
    self:addChild(self._pularContemLabel)
    
    
    self._verRespostaContemPanel = Panel {      
      backgroundTexture = "minigames/assets/panel.png",                
      parent = self,            
    }       
    
    self._verRespostaContemLabel = Label("0X VER RESPOSTA", nil,nil, font, 30)        
    self._verRespostaContemLabel:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
    self:addChild(self._verRespostaContemLabel)
              
    self._comprarItensLabel = Label("COMPRAR ITENS", nil, nil, font, 20)        
    self:addChild(self._comprarItensLabel)
    
    self._comprarPularButton = Button {                        
      normalTexture = "minigames/assets/compraPular-button-normal.png",
      selectedTexture = "minigames/assets/compraPular-button-selected.png",
      textColor = {1,1,1,1},
      onClick = function(e)
          self:dispatchEvent("compraPular", e)
      end,      
      parent = self
    }                
    
    self._comprarVerRespostaButton = Button {                        
      normalTexture = "minigames/assets/compraVerResposta-button-normal.png",
      selectedTexture = "minigames/assets/compraVerResposta-button-selected.png",
      textColor = {1,1,1,1},
      onClick = function(e)
          self:dispatchEvent("compraVerResposta", e)
      end,      
      parent = self
    }                 
    
    self._backButton = ImageButton {                        
      normalTexture = "minigames/assets/back.png",
      selectedTexture = "minigames/assets/backHover.png",      
      onClick = function(e)
          self:dispatchEvent("back", e)
      end,      
      parent = self
    }                  
end


function LojaView:updateDisplay()
    LojaView.__super.updateDisplay(self)   
    
    local xOffset,yOffset = 50, 50
    self._mainBackground:setSize(self:getWidth(),self:getHeight())
    self._mainBackground:setPos(xOffset,yOffset)
            
    -- BOTÃO COMPRA PULAR
    self._comprarPularButton:setSize(200, self:getHeight() / 8)
    self._comprarPularButton:setPos(self:getWidth() / 2 - 200 + xOffset, self._mainBackground:getBottom() - self._comprarPularButton:getHeight() - self:getHeight() / 8)
        
    -- BOTÃO COMPRA VER RESPOSTA    
    self._comprarVerRespostaButton:setSize(self._comprarPularButton:getWidth(), self._comprarPularButton:getHeight())    
    self._comprarVerRespostaButton:setPos(self._comprarPularButton:getRight() + 10, self._mainBackground:getBottom() - self._comprarVerRespostaButton:getHeight() - self:getHeight() / 8)
    
    -- LABEL ITENS COMPRA
    self._comprarItensLabel:setPos(self._comprarPularButton:getLeft(), self._comprarVerRespostaButton:getTop() - self._comprarItensLabel:getHeight())
                      
    
    -- PANEL DE EXIBIÇÃO DOS PULOS
    self._pularContemPanel:setSize(200, self:getHeight() / 8)
    self._pularContemPanel:setPos(self:getWidth() / 2 - 200 + xOffset, self._comprarItensLabel:getTop() - self._pularContemPanel:getHeight() - 10)    
    
    local pular = string.format("%dX PULOS", self._playerData.pular)
    self._pularContemLabel:setString(pular)
    self._pularContemLabel:setPos(self._pularContemPanel:getLeft(), self._pularContemPanel:getTop())            
    self._pularContemLabel:setSize(self._pularContemPanel:getWidth(), self._pularContemPanel:getHeight())
    self._pularContemLabel:setTextSize(self._pularContemPanel:getHeight() / 4)
    
    --  PANEL DE EXIBIÇÃO VER RESPOSTA
    self._verRespostaContemPanel:setPos(self._pularContemPanel:getRight() + 10, self._pularContemPanel:getTop())
    self._verRespostaContemPanel:setSize(200, self:getHeight() / 8)
    
    local verResposta = string.format("%dX VER RESPOSTA", self._playerData.verResposta)
    self._verRespostaContemLabel:setString(verResposta)

    self._verRespostaContemLabel:setPos(self._verRespostaContemPanel:getLeft(), self._verRespostaContemPanel:getTop()) 
    self._verRespostaContemLabel:setSize(self._verRespostaContemPanel:getWidth(),self._verRespostaContemPanel:getHeight())
    self._verRespostaContemLabel:setTextSize(self._verRespostaContemPanel:getHeight() / 4)
    
    -- LABEL MEUS ITENS
    self._meusItensLabel:setPos(self._comprarPularButton:getLeft(), self._pularContemPanel:getTop() - self._meusItensLabel:getHeight())
    
    self._backButton:setPos(self._mainBackground:getLeft(),self._mainBackground:getBottom() - self._backButton:getHeight())
end


function LojaView:setPlayerData(data)      
    self._playerData = data
end




return M