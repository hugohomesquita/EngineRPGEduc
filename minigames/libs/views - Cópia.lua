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
    
    self.msg:setSize(self.mainPanel:getWidth(),40)
    self.msg:setPos(self.mainPanel:getWidth()/2 , self.mainPanel:getHeight())
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
    
    self._lojaLabel = Label("LOJA", nil, nil, font, 20)        
    self:addChild(self._lojaLabel)
    
    self._meusItensLabel = Label("MEUS ITENS", nil, nil, font, 20)        
    self:addChild(self._meusItensLabel)
    
    self._pularContemPanel = Panel {      
      backgroundTexture = "minigames/assets/panel.png",                
      parent = self,            
    }   
    self:addChild(self._pularContemPanel)
    
    self._pularContemLabel = Label("0X PULAR", nil, nil, font, 30)        
    self._pularContemLabel:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
    self:addChild(self._pularContemLabel)
    
    
    self._verRespostaContemPanel = Panel {      
      backgroundTexture = "minigames/assets/panel.png",                
      parent = self,            
    }   
    self:addChild(self._verRespostaContemPanel)
    
    self._verRespostaContemLabel = Label("0X VER RESPOSTA", nil,nil, font, 30)        
    self._verRespostaContemLabel:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.CENTER_JUSTIFY)
    self:addChild(self._verRespostaContemLabel)
              
    self._comprarItensLabel = Label("COMPRAR ITENS", nil, nil, font, 20)        
    self:addChild(self._comprarItensLabel)
    
    self._comprarPularButton = Button {                        
      normalTexture = "minigames/assets/compraPular-button-normal.png",
      selectedTexture = "minigames/assets/compraPular-button-selected.png",
      onClick = function(e)
          self:dispatchEvent("compraPular", e)
      end,      
      parent = self
    }        
    self._comprarPularButton:setTextColor(1,1,1,1)    
    self:addChild(self._comprarPularButton)
    
    self._comprarVerRespostaButton = ImageButton {                        
      normalTexture = "minigames/assets/compraVerResposta-button-normal.png",
      selectedTexture = "minigames/assets/compraVerResposta-button-selected.png",
      onClick = function(e)
          self:dispatchEvent("compraVerResposta", e)
      end,      
      parent = self
    }        
    self._comprarVerRespostaButton:setTextColor(1,1,1,1)    
    self:addChild(self._comprarVerRespostaButton)
    
    self._backButton = ImageButton {                        
      normalTexture = "minigames/assets/back.png",
      selectedTexture = "minigames/assets/backHover.png",      
      onClick = function(e)
          self:dispatchEvent("back", e)
      end,      
      parent = self
    }              
    self:addChild(self._backButton)    
end


function LojaView:updateDisplay()
    LojaView.__super.updateDisplay(self)   
    
    local xOffset,yOffset = 50, 50
    self._mainBackground:setSize(self:getWidth(),self:getHeight())
    self._mainBackground:setPos(xOffset,yOffset)
    
    self._lojaLabel:setPos(self:getWidth() / 2 - self._lojaLabel:getWidth() / 2 + xOffset, self:getHeight() / 2 - self._lojaLabel:getHeight() / 2 + yOffset)    
    
    self._meusItensLabel:setPos(self:getWidth() / 2 - self._lojaLabel:getWidth() / 2 - 175 + xOffset, self:getHeight() / 2 - self._lojaLabel:getHeight() / 2 + 15 + yOffset)
    
    self._pularContemPanel:setPos(self:getWidth() / 2 - 200 + xOffset, self._meusItensLabel:getBottom())
    self._pularContemPanel:setSize(200, 60)
                
    local pular = string.format("%dX PULAR", self._playerData.pular)
    self._pularContemLabel:setString(pular)
    self._pularContemLabel:setPos(self._pularContemPanel:getLeft(), self._pularContemPanel:getTop())            
    self._pularContemLabel:setSize(self._pularContemPanel:getWidth(), self._pularContemPanel:getHeight())
    self._pularContemLabel:setTextSize(self._pularContemPanel:getHeight()/4)
    
    
    self._verRespostaContemPanel:setPos(self._pularContemPanel:getRight() + 10, self._meusItensLabel:getBottom())
    self._verRespostaContemPanel:setSize(200, 60)
    
    local verResposta = string.format("%dX VER RESPOSTA", self._playerData.verResposta)
    self._verRespostaContemLabel:setString(verResposta)

    self._verRespostaContemLabel:setPos(self._verRespostaContemPanel:getLeft(), self._verRespostaContemPanel:getTop()) 
    self._verRespostaContemLabel:setSize(self._verRespostaContemPanel:getWidth(),self._verRespostaContemPanel:getHeight())
    self._verRespostaContemLabel:setTextSize(self._verRespostaContemPanel:getHeight()/4)
    
    
    self._comprarItensLabel:setPos(self._meusItensLabel:getLeft(), self._pularContemPanel:getBottom() + 10)
    
    self._comprarPularButton:setSize(200, 60)
    self._comprarPularButton:setPos(self._pularContemPanel:getLeft(),self._comprarItensLabel:getBottom())
        
    self._comprarVerRespostaButton:setPos(self._verRespostaContemPanel:getLeft(),self._comprarItensLabel:getBottom())
    
    
    self._backButton:setPos(self._mainBackground:getLeft(),self._mainBackground:getBottom() - self._backButton:getHeight())
end


function LojaView:setPlayerData(data)      
    self._playerData = data
end

--------------------------------------------------------------------------------
-- @type AvatarView
-- 
--------------------------------------------------------------------------------
AvatarView = class(UIView)
M.AvatarView = AvatarView

function AvatarView:init(params)            
    AvatarView.__super.init(self, params)    
end

function AvatarView:_createChildren()    
    AvatarView.__super._createChildren(self)   
    
    local font = flower.getFont("minigames/assets/fonts/SHOWG.TTF", nil, 18)        
    
    self._mainPanel = Panel {      
      backgroundTexture = "minigames/assets/panel.png",
      size = {200, 100},
      pos = {5, 5},      
      parent = self,            
    }       
    self:addChild(self._mainPanel)
       
    self._avatarImage = flower.Image("avatars/avatar1.png", 80, 80)
    self._avatarImage:setPos(self._mainPanel:getLeft() + 2, self._mainPanel:getTop() + 5)
    self:addChild(self._avatarImage)   
       
    self._avatarName = Label("Hugo Mesquita", nil, nil, font, 14)
    self._avatarName:setPos(self._avatarImage:getRight(), self._mainPanel:getTop() + 10)    
    self:addChild(self._avatarName)
    
    self._avatarLVL = Label("LEVEL 10", nil, nil, font, 13)
    self._avatarLVL:setPos(self._avatarImage:getRight(), self._avatarName:getBottom())    
    
    self._avatarXP = Label("XP 80/100", nil, nil, font, 13)
    self._avatarXP:setPos(self._avatarImage:getRight(), self._avatarLVL:getBottom())
    
    self:addChild(self._avatarLVL)
    self:addChild(self._avatarXP)       
    
    self._goldImage = flower.Image("minigames/assets/coins.png", 20, 20)
    self._goldImage:setPos(self._avatarImage:getRight(), self._avatarXP:getBottom())
    self:addChild(self._goldImage)
    
    self._avatarGOLD = Label("999999", nil, nil, font, 13)
    self._avatarGOLD:setPos(self._goldImage:getRight() + 5, self._avatarXP:getBottom() + 3)    
    self:addChild(self._avatarGOLD)
       
end

function AvatarView:updateDisplay()
    AvatarView.__super.updateDisplay(self)   
    
    local texture = self._player.actor.texture
    self._avatarImage:setTexture(texture)
    self._avatarImage:setSize(80,80)
    
    local gold = tostring(self._player.gold)    
    self._avatarGOLD:setString(gold)
    self._avatarGOLD:fitSize(#gold)
    
    local name = self._player.actor.name
    self._avatarName:setString(name)
    self._avatarName:fitSize(#name)    
    
    local level = string.format("LEVEL  %d", self._player.actor.level)
    self._avatarLVL:setString(level)
    self._avatarLVL:fitSize(#level)
    
    local xp = string.format("XP  %d/%d", self._player.actor.exp,(self._player.actor.level+1)*100)
    self._avatarXP:setString(xp)
    self._avatarXP:fitSize(#xp)
end

function AvatarView:setPlayer(player)
    self._player = player
end

--------------------------------------------------------------------------------
-- @type ActorDetailBox
--------------------------------------------------------------------------------



return M