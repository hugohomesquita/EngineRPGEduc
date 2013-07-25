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
local ResultQuestionView
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
    
    self.mainPanel = Panel {
        size = {flower.viewWidth - 100, flower.viewHeight - 100},
        pos = {50,50},
        parent = self
    }
    
    self.mainQuestionPanel = Panel {
        size = {self.mainPanel:getWidth() - 20, 120},
        pos = {self.mainPanel:getLeft() + 10, self.mainPanel:getTop() + 10},
        parent = self
    }
                  
    self.mainQuestion = Label("", self.mainPanel:getWidth() - 20, 120, nil, 18)
    self.mainQuestion:setPos(self.mainQuestionPanel:getLeft() + 10, self.mainQuestionPanel:getTop() + 10)    
    self:addChild(self.mainQuestion)
    
    self.answerA = Button {
        text = "ALTERNATIVA A",
        size = {self.mainQuestion:getWidth() / 2, 50},
        pos = {self.mainPanel:getLeft() + 10, self.mainQuestionPanel:getBottom() + 5},
        onClick = function(e)
            self:dispatchEvent("selectAnswer", e)
        end,
    }
    self:addChild(self.answerA)
    
    self.answerB = Button {
        text = "ALTERNATIVA B",
        size = {self.mainQuestion:getWidth() / 2, 50},
        pos = {self.mainPanel:getLeft() + 10, self.answerA:getBottom() + 5},
        onClick = function(e)
            self:dispatchEvent("selectAnswer", e)
        end,
    }
    self:addChild(self.answerB)    
    
    self.answerC = Button {
        text = "ALTERNATIVA C",
        size = {self.mainQuestion:getWidth() / 2, 50},
        pos = {self.mainPanel:getLeft() + 10, self.answerB:getBottom() + 5},
        onClick = function(e)
            self:dispatchEvent("selectAnswer", e)
        end,
    }
    self:addChild(self.answerC)
    
    self.answerD = Button {
        text = "ALTERNATIVA D",
        size = {self.mainQuestion:getWidth() / 2, 50},
        pos = {self.mainPanel:getLeft() + 10, self.answerC:getBottom() + 5},
        onClick = function(e)
            self:dispatchEvent("selectAnswer", e)
        end,
    }
    self:addChild(self.answerD)
    
    --INFO THE PLAYER    
    self.mainPlayerPanel = Panel {
        size = {100, self.mainPanel:getHeight() - 140},
        pos = {self.mainPanel:getRight() - 110, self.mainQuestion:getBottom() - 5},
        parent = self
    }
    
    avatar = flower.Image("avatars/avatar1.png", 100, 100)
    avatar:setPos(self.mainPlayerPanel:getRight() - avatar:getWidth() - 5, self.mainPlayerPanel:getTop() + 5)
    self:addChild(avatar)
    
    avatarNameLabel = Label("", avatar:getWidth(), 20, nil, 14)
    avatarNameLabel:setPos(avatar:getLeft(), avatar:getBottom() + 5)
    self:addChild(avatarNameLabel)
    
    avatarLVLNameLabel = Label("LVL", 30, 17, nil, 13)
    avatarLVLNameLabel:setPos(avatar:getLeft(), avatarNameLabel:getBottom())    
    avatarLVLValueLabel = Label("0", 30, 17, nil, 13)
    avatarLVLValueLabel:setPos(avatarLVLNameLabel:getRight(), avatarNameLabel:getBottom())
    
    self:addChild(avatarLVLNameLabel)
    self:addChild(avatarLVLValueLabel)
    
    avatarEXPNameLabel = Label("EXP", 30, 17, nil, 13)
    avatarEXPNameLabel:setPos(avatar:getLeft(), avatarLVLNameLabel:getBottom())    
    avatarEXPValueLabel = Label("0", 30, 17, nil, 13)
    avatarEXPValueLabel:setPos(avatarEXPNameLabel:getRight(), avatarLVLNameLabel:getBottom())
    
    self:addChild(avatarEXPNameLabel)
    self:addChild(avatarEXPValueLabel)
    
    avatarCoinsNameLabel = Label("MOEDAS", 55, 17, nil, 13)
    avatarCoinsNameLabel:setPos(avatar:getLeft(), avatarEXPNameLabel:getBottom())    
    avatarCoinsValueLabel = Label("0", 50, 17, nil, 13)
    avatarCoinsValueLabel:setPos(avatarCoinsNameLabel:getRight(), avatarEXPNameLabel:getBottom())
    
    self:addChild(avatarCoinsNameLabel)
    self:addChild(avatarCoinsValueLabel)
    
    self.pular = Button {
        text = "3x Pular",
        size = {140, 50},
        pos = {self.mainPanel:getLeft() + 10, self.answerD:getBottom() + 40},
        onClick = function(e)
            self:dispatchEvent("jump", e)
        end,

    }
    self:addChild(self.pular)
    
    self.parar = Button {
        text = "Parar",
        size = {140, 50},
        pos = {self.pular:getRight()+10, self.pular:getTop()},
        onClick = function(e)
            self:dispatchEvent("stop", e)
        end,
    }
    self:addChild(self.parar)
        
        
    pontosLabelParar = Label("Parar", 40, 17, nil, 13)
    pontosLabelParar:setPos(self.mainPanel:getWidth() / 3 - 20, self.mainPanel:getBottom()-40)
    self:addChild(pontosLabelParar)    
    pontosValueParar = Label("1000", 40, 17, nil, 13)
    pontosValueParar:setPos(pontosLabelParar:getLeft(), pontosLabelParar:getBottom()+2)
    self:addChild(pontosValueParar)
    
    
    -- PONTOS
    pontosLabelErrar = Label("Errar", 40, 17, nil, 13)
    pontosLabelErrar:setPos(pontosLabelParar:getLeft() - 80, pontosLabelParar:getTop())
    self:addChild(pontosLabelErrar)    
    pontosValueErrar = Label("500", 40, 17, nil, 13)
    pontosValueErrar:setPos(pontosLabelErrar:getLeft(), pontosLabelErrar:getBottom()+2)
    self:addChild(pontosValueErrar)
    
    
    pontosLabelAcertar = Label("Acertar", 50, 17, nil, 13)
    pontosLabelAcertar:setPos(pontosLabelParar:getRight() + 40, pontosLabelErrar:getTop())
    self:addChild(pontosLabelAcertar)    
    pontosValueAcertar = Label("2000", 50, 17, nil, 13)
    pontosValueAcertar:setPos(pontosLabelAcertar:getLeft(), pontosLabelAcertar:getBottom()+2)
    self:addChild(pontosValueAcertar)
    
    self.listQuestionsDisplayed = {}  
    self.totalQuestions = 0
    
    self.questions = {}
    self:initQuestions()
end

function QuizQuestionView:updateDisplay()
    QuizQuestionView.__super.updateDisplay(self)
    
    --UPDATE THE PLAYER INFO
    
    avatar:setTexture(self._player.texture)
    avatar:setSize(100, 100)
    avatarNameLabel:setString(self._player.name)
    
    avatarLVLValueLabel:setString(tostring(self._player.level))
    avatarEXPValueLabel:setString(tostring(self._player.exp))
    avatarCoinsValueLabel:setString(tostring(self._player.coins))
    
    self:nextQuestion()
end

function QuizQuestionView:initQuestions()
    self.questions = dofile('minigames/data/questoes.lua')    
    self.totalQuestions = #self.questions    
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

function QuizQuestionView:setPlayer(player)
    self._player = player
end

--------------------------------------------------------------------------------
-- @type QuizQuestionView
-- 
--------------------------------------------------------------------------------
ResultQuestionView = class(UIView)
M.ResultQuestionView = ResultQuestionView

---
-- コンストラクタ
-- @param params パラメータ
function ResultQuestionView:init(params)    
    ResultQuestionView.__super.init(self, params)
end

---
-- 子オブジェクトを生成します.
function ResultQuestionView:_createChildren()    
    ResultQuestionView.__super._createChildren(self)   
    
    self.mainPanel = Panel {
        size = {flower.viewWidth - 100, flower.viewHeight - 100},
        pos = {50, 50},
        parent = self
    }    
    self.mainPanel:addEventListener(Event.TOUCH_DOWN, self.onTouchDown, self)    
end

function ResultQuestionView:onTouchDown(e)
    self:dispatchEvent("close")
end
function ResultQuestionView:updateDisplay()
    ResultQuestionView.__super.updateDisplay(self)           
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
    
    self._menuPrincipalLabel = Label("MENU PRINCIPAL", nil, nil, font, 20)    
    self._menuPrincipalLabel:setPos(self:getWidth() / 2 - self._menuPrincipalLabel:getWidth() / 2, self:getHeight() / 2 - self._menuPrincipalLabel:getHeight() / 2)
    self:addChild(self._menuPrincipalLabel)
    
    self._btComecar = Button {      
      text = "COMEÇAR",
      size = {400, 83},
      pos = {self:getWidth() / 2 - 200, self._menuPrincipalLabel:getBottom() + 15},
      normalTexture = "minigames/assets/button-normal.png",
      selectedTexture = "minigames/assets/button-selected.png",
      onClick = function(e)
          self:dispatchEvent("comecar", e)
      end,      
      parent = self
    }    
    self._btComecar:setTextSize(30)
    self._btComecar:setStyle("fontName",font)    
    self._btComecar:setTextColor(1,1,1,1)    
    self:addChild(self._btComecar)
    
    self._btLoja = Button {      
      text = "LOJA",
      size = {400, 83},
      pos = {self:getWidth() / 2 - 200, self._btComecar:getBottom() + 15},
      normalTexture = "minigames/assets/button-normal.png",
      selectedTexture = "minigames/assets/button-selected.png",
      onClick = function(e)
          self:dispatchEvent("loja", e)
      end,      
      parent = self
    }    
    self._btLoja:setTextSize(30)
    self._btLoja:setStyle("fontName",font)    
    self._btLoja:setTextColor(1,1,1,1)    
    self:addChild(self._btLoja)
       
end

function MenuPrincipalView:updateDisplay()
    MenuPrincipalView.__super.updateDisplay(self)       
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
    
    self._menuPrincipalLabel = Label("LOJA", nil, nil, font, 20)    
    self._menuPrincipalLabel:setPos(self:getWidth() / 2 - self._menuPrincipalLabel:getWidth() / 2, self:getHeight() / 2 - self._menuPrincipalLabel:getHeight() / 2)
    self:addChild(self._menuPrincipalLabel)
    
    self._meusItensLabel = Label("MEUS ITENS", nil, nil, font, 20)    
    self._meusItensLabel:setPos(self:getWidth() / 2 - self._menuPrincipalLabel:getWidth() / 2 - 175, self:getHeight() / 2 - self._menuPrincipalLabel:getHeight() / 2 + 15)
    self:addChild(self._meusItensLabel)
    
    self._pularContemPanel = Panel {      
      backgroundTexture = "minigames/assets/panel.png",
      size = {200, 83},
      pos = {self:getWidth() / 2 - 200, self._meusItensLabel:getBottom()},      
      parent = self,            
    }   
    self:addChild(self._pularContemPanel)
    
    self._pularContemLabel = Label("0X PULAR", self._pularContemPanel:getWidth(), self._pularContemPanel:getHeight(), font, 30)    
    self._pularContemLabel:setPos(self._pularContemPanel:getLeft(), self._pularContemPanel:getTop())    
    self._pularContemLabel:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
    self:addChild(self._pularContemLabel)
    
    
    self._verRespostaContemPanel = Panel {      
      backgroundTexture = "minigames/assets/panel.png",
      size = {200, 83},
      pos = {self._pularContemPanel:getRight() + 10, self._meusItensLabel:getBottom()},      
      parent = self,            
    }   
    self:addChild(self._verRespostaContemPanel)
    
    self._verRespostaContemLabel = Label("0X VER RESPOSTA", self._verRespostaContemPanel:getWidth(), self._verRespostaContemPanel:getHeight(), font, 30)    
    self._verRespostaContemLabel:setPos(self._verRespostaContemPanel:getLeft(), self._verRespostaContemPanel:getTop())    
    self._verRespostaContemLabel:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
    self:addChild(self._verRespostaContemLabel)
    
    
    
    
    self._comprarItensLabel = Label("COMPRAR ITENS", nil, nil, font, 20)    
    self._comprarItensLabel:setPos(self:getWidth() / 2 - self._menuPrincipalLabel:getWidth() / 2 - 175, self._pularContemPanel:getBottom() + 10)
    self:addChild(self._comprarItensLabel)
        
    
    
end

function LojaView:updateDisplay()
    LojaView.__super.updateDisplay(self)       
end


return M