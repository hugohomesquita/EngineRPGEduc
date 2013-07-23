-- module
local M = {}

-- import
local flower = require "hanappe/flower"
local widget = require "hanappe/extensions/widget"
local class = flower.class
local table = flower.table

local Label = flower.Label
local Panel = widget.Panel



local InputMgr = flower.InputMgr

local Event = flower.Event
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

-- consts


--
local WIDGET_WIDTH = 320

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
              
    
    self.mainQuestion = Label("DOIS MINUTOS SOMADOS A TRÊS GRAUS RESULTA EM: DOIS MINUTOS SOMADOS A TRÊS GRAUS RESULTA EM:", self.mainPanel:getWidth() - 20, 120, nil, 18)
    self.mainQuestion:setPos(self.mainQuestionPanel:getLeft() + 10, self.mainQuestionPanel:getTop() + 10)    
    self:addChild(self.mainQuestion)
    
    self.answerA = Button {
        text = "ALTERNATIVA A",
        size = {self.mainQuestion:getWidth() / 2, 50},
        pos = {self.mainPanel:getLeft() + 10, self.mainQuestionPanel:getBottom() + 5}
    }
    self:addChild(self.answerA)
    
    self.answerB = Button {
        text = "ALTERNATIVA B",
        size = {self.mainQuestion:getWidth() / 2, 50},
        pos = {self.mainPanel:getLeft() + 10, self.answerA:getBottom() + 5}
    }
    self:addChild(self.answerB)
    
    self.answerB = Button {
        text = "ALTERNATIVA B",
        size = {self.mainQuestion:getWidth() / 2, 50},
        pos = {self.mainPanel:getLeft() + 10, self.answerA:getBottom() + 5}
    }
    self:addChild(self.answerB)
    
    self.answerC = Button {
        text = "ALTERNATIVA C",
        size = {self.mainQuestion:getWidth() / 2, 50},
        pos = {self.mainPanel:getLeft() + 10, self.answerB:getBottom() + 5}
    }
    self:addChild(self.answerC)
    
    self.answerD = Button {
        text = "ALTERNATIVA D",
        size = {self.mainQuestion:getWidth() / 2, 50},
        pos = {self.mainPanel:getLeft() + 10, self.answerC:getBottom() + 5}
    }
    self:addChild(self.answerD)
    
    --INFO THE PLAYER    
    self.mainPlayerPanel = Panel {
        size = {self.mainQuestion:getWidth() / 2 - 10, self.mainPanel:getHeight() - 140},
        pos = {self.mainQuestion:getRight() - self.mainQuestion:getWidth() / 2, self.mainQuestion:getBottom() - 5},
        parent = self
    }
    
    avatar = flower.Image("avatars/avatar1.png", 100, 100)
    avatar:setPos(self.mainPlayerPanel:getRight() - avatar:getWidth() - 5, self.mainPlayerPanel:getTop() + 5)
    self:addChild(avatar)
    
    avatarNameLabel = Label("Hugo Mesquita", avatar:getWidth(), 20, nil, 14)
    avatarNameLabel:setPos(avatar:getLeft(), avatar:getBottom() + 5)
    self:addChild(avatarNameLabel)
    
    avatarLVLNameLabel = Label("LVL", 30, 17, nil, 13)
    avatarLVLNameLabel:setPos(avatar:getLeft(), avatarNameLabel:getBottom())    
    avatarLVLValueLabel = Label("68", 30, 17, nil, 13)
    avatarLVLValueLabel:setPos(avatarLVLNameLabel:getRight(), avatarNameLabel:getBottom())
    
    self:addChild(avatarLVLNameLabel)
    self:addChild(avatarLVLValueLabel)
    
    avatarEXPNameLabel = Label("EXP", 30, 17, nil, 13)
    avatarEXPNameLabel:setPos(avatar:getLeft(), avatarLVLNameLabel:getBottom())    
    avatarEXPValueLabel = Label("20", 30, 17, nil, 13)
    avatarEXPValueLabel:setPos(avatarEXPNameLabel:getRight(), avatarLVLNameLabel:getBottom())
    
    self:addChild(avatarEXPNameLabel)
    self:addChild(avatarEXPValueLabel)
    
    self.pular = Button {
        text = "PULAR | 10K",
        size = {140, 50},
        pos = {self.mainPlayerPanel:getLeft() + 10, self.mainPlayerPanel:getBottom() - 60}
    }
    self:addChild(self.pular)
    
    self.parar = Button {
        text = "Parar",
        size = {140, 50},
        pos = {self.pular:getRight()+10, self.pular:getTop()}
    }
    self:addChild(self.parar)
        
    
    pontosLabelParar = Label("Parar", 40, 17, nil, 13)
    pontosLabelParar:setPos(self.mainPanel:getWidth() / 3 - 20, self.mainPanel:getBottom()-40)
    self:addChild(pontosLabelParar)    
    pontosValueParar = Label("1K", 40, 17, nil, 13)
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
    pontosValueAcertar = Label("2K", 50, 17, nil, 13)
    pontosValueAcertar:setPos(pontosLabelAcertar:getLeft(), pontosLabelAcertar:getBottom()+2)
    self:addChild(pontosValueAcertar)
    
end

return M