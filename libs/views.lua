----------------------------------------------------------------------------------------------------
-- Módulo que define as classes Views.
-- 
-- A View é uma coleção de peças que consiste em mais de um widget.
----------------------------------------------------------------------------------------------------


-- module
local M = {}

-- import
local flower = require "hanappe/flower"
local widget = require "hanappe/extensions/widget"
local widgets = require "libs/widgets"
local entities = require "libs/entities"
local repositry = entities.repositry
local InputMgr = flower.InputMgr
local class = flower.class
local table = flower.table
local Event = flower.Event
local Image = flower.Image
local Label = flower.Label
local ImageButton = widget.ImageButton
local NineImage = flower.NineImage
local UIView = widget.UIView
local Joystick = widget.Joystick
local Button = widget.Button
local ListBox = widget.ListBox
local ListItem = widget.ListItem
local TextBox = widget.TextBox

local ActorStatusBox = widgets.ActorStatusBox
local ActorDetailBox = widgets.ActorDetailBox
local SkillListBox = widgets.SkillListBox
local MemberListBox = widgets.MemberListBox

-- classes
local TitleMenuView
local NewGameView
local AvatarView

-- consts
local STICK_TO_DIR = {
    top = "north",
    left = "west",
    right = "east",
    bottom = "south"
}

local KeyCode = {}
KeyCode.LEFT = string.byte("a")
KeyCode.RIGHT = string.byte("d")
KeyCode.UP = string.byte("w")
KeyCode.DOWN = string.byte("s")

-- ウィジェットの最大の横幅
local WIDGET_WIDTH = 320

--------------------------------------------------------------------------------
-- @type TitleMenuView
-- Classe de visualização para exibir o menu de títulos.
--------------------------------------------------------------------------------
TitleMenuView = class(UIView)
M.TitleMenuView = TitleMenuView

---
-- Criando um Objeto.
function TitleMenuView:_createChildren()
    TitleMenuView.__super._createChildren(self)
    
    self.titleImage = NineImage("bg_main.png", flower.viewWidth, flower.viewHeight)    
    self:addChild(self.titleImage)
            
    self.newButton = Button {
        text = "Novo Jogo",        
        textColor = {1,1,1,1},        
        fontName = "SHOWG.TTF",
        normalTexture = "minigames/assets/button-normal.png",
        selectedTexture = "minigames/assets/button-selected.png",
        pos = {math.floor(flower.viewWidth / 2 - 100), math.floor(flower.viewHeight / 2)},
        parent = self,
        onClick = function(e)
            self:dispatchEvent("newGame")
        end,        
    }    
    self.loadButton = Button {
        text = "Carregar Jogo",        
        textColor = {1,1,1,1},        
        fontName = "SHOWG.TTF",
        normalTexture = "minigames/assets/button-normal.png",
        selectedTexture = "minigames/assets/button-selected.png",
        pos = {self.newButton:getLeft(), self.newButton:getBottom() + 10},
        parent = self,
        onClick = function(e)
            self:dispatchEvent("loadGame")
        end,        
    }
    self.optionButton = Button {
        text = "Opcões",        
        textColor = {1,1,1,1},        
        fontName = "SHOWG.TTF",
        normalTexture = "minigames/assets/button-normal.png",
        selectedTexture = "minigames/assets/button-selected.png",
        pos = {self.loadButton:getLeft(), self.loadButton:getBottom() + 10},
        parent = self,
        onClick = function(e)
            self:dispatchEvent("optionGame")
        end,        
    }    
    
end

function TitleMenuView:updateDisplay()
    TitleMenuView.__super.updateDisplay(self)
    
    local vw, vh = flower.getViewSize()
    local midVW = math.floor(vw / 2)
    local midVH = math.floor(vh / 2)
   
    local sizeButtonW, sizeButtonH = midVW, midVH / 3    
    local posButtonX, posButtonY = midVW - sizeButtonW / 2, midVH - sizeButtonH / 2
    
    self.newButton:setPos(posButtonX, posButtonY)
    self.newButton:setSize(sizeButtonW,sizeButtonH)               

    self.loadButton:setPos(self.newButton:getLeft(), self.newButton:getBottom() + 10)
    self.loadButton:setSize(sizeButtonW,sizeButtonH)
    
    self.optionButton:setPos(self.loadButton:getLeft(), self.loadButton:getBottom() + 10)
    self.optionButton:setSize(sizeButtonW,sizeButtonH)
            
end

--------------------------------------------------------------------------------
-- @type NewGameView
-- Classe de visualização para exibir o menu de criação do avatar.
--------------------------------------------------------------------------------
NewGameView = class(UIView)
M.NewGameView = NewGameView

---
-- Criando um Objeto.
function NewGameView:_createChildren()
    NewGameView.__super._createChildren(self)
    
    --1 = MASCULINO
    --2 = FEMININO
    self.genderPlayer = nil
    
    self.titleImage = NineImage("bg_main.png", flower.viewWidth, flower.viewHeight)    
    self:addChild(self.titleImage)
    
    local font = flower.getFont("fonts/SHOWG.TTF", nil, 18)  
    
    self.genderLabel = Label("Selecione o sexo do seu avatar", nil, nil, font, 30)    
    self:addChild(self.genderLabel)
    
    self.male = Button {                
        normalTexture = "avatars/avatar1-button-normal.png",
        selectedTexture = "avatars/avatar1-button-selected.png",      
        parent = self,        
        onClick = function(e)
            self:dispatchEvent("selectMale")
        end,        
    }    
    self.maleLabel = Label("Masculino", nil, nil, font, 16)    
    self:addChild(self.maleLabel)
    
    self.female = Button {        
        normalTexture = "avatars/avatar2-button-normal.png",
        selectedTexture = "avatars/avatar2-button-selected.png",      
        parent = self,
        onClick = function(e)
            self:dispatchEvent("selectFemale")
        end,        
    }
    self:addEventListener("selectMale", self.onSelectGender, self)
    self:addEventListener("selectFemale", self.onSelectGender, self)
    
    self.femaleLabel = Label("Feminino", nil, nil, font, 16)    
    self:addChild(self.femaleLabel)
    
    
    self.nameLabel = Label("Insira o nome do Avatar", nil, nil, font, 30)    
    self:addChild(self.nameLabel)
    
    self.nameInput = widget.TextInput {
        size = {50,20},
        pos = {0,0},
        textColor = {0,0,0,1},
        parent = self
    }
    
    self.iniciar = Button {
        text = "Iniciar Jogo",        
        textColor = {1,1,1,1},        
        fontName = "SHOWG.TTF",
        normalTexture = "minigames/assets/button-normal.png",
        selectedTexture = "minigames/assets/button-selected.png",      
        parent = self,
        onClick = function(e)
            e.name = self.nameInput:getText()
            e.gender = self.genderPlayer
            self:dispatchEvent("initGame", e)
        end,        
    }
    
    self._backButton = ImageButton {                        
      normalTexture = "assets/back.png",
      selectedTexture = "assets/backHover.png",      
      onClick = function(e)
          self:dispatchEvent("back", e)
      end,      
      parent = self
    } 
end

function NewGameView:onSelectGender(e)
    if(e.type == "selectMale") then
        self.female:setNormalTexture("avatars/avatar2-button-normal.png")
        self.male:setNormalTexture("avatars/avatar1-button-selected.png")
        self.genderPlayer = 1
    else
        self.male:setNormalTexture("avatars/avatar1-button-normal.png")
        self.female:setNormalTexture("avatars/avatar2-button-selected.png")
        self.genderPlayer = 2
    end    
end

function NewGameView:updateDisplay()
    NewGameView.__super.updateDisplay(self)
    
    local vw, vh = flower.getViewSize()
    local mW = math.floor(vw / 2)
    local mH = math.floor(vh / 2)
    local sizeButtonW, sizeButtonH = mW, mH / 3  
    
    self.genderLabel:setPos(mW - self.genderLabel:getWidth()/2, 50)
    
    self.male:setSize(200, 200)
    self.male:setPos(mW - self.male:getWidth() - 50, self.genderLabel:getBottom() + 20)    
    self.maleLabel:setSize(self.male:getLeft() + self.male:getRight(), self.maleLabel:getHeight())
    self.maleLabel:setPos(0, self.male:getBottom() + 5)      
    self.maleLabel:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
    
    
    self.female:setSize(200, 200)
    self.female:setPos(mW + 50, self.male:getTop())  
    self.femaleLabel:setSize(self.female:getLeft() + self.female:getRight(), self.femaleLabel:getHeight())
    self.femaleLabel:setPos(0, self.female:getBottom() + 5)
    self.femaleLabel:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
            
    self.nameLabel:setSize(self.male:getLeft() + self.female:getRight(), self.nameLabel:getHeight())
    self.nameLabel:setPos(0, self.femaleLabel:getBottom() + 40)
    self.nameLabel:setAlignment(MOAITextBox.CENTER_JUSTIFY, MOAITextBox.LEFT_JUSTIFY)
    
    self.nameInput:setSize(mW/2, 50)
    self.nameInput:setPos(mW - self.nameInput:getWidth()/2, self.nameLabel:getBottom() + 10)
    
    self.iniciar:setSize(sizeButtonW, sizeButtonH)
    self.iniciar:setPos(mW - self.iniciar:getWidth()/2, self.nameInput:getBottom() + 60)
    
    self._backButton:setPos(self.titleImage:getLeft(),self.titleImage:getBottom() - self._backButton:getHeight())
end

--------------------------------------------------------------------------------
-- @type LoadGameView
-- Classe de visualização para exibir o menu para carregar o jogo salvo.
--------------------------------------------------------------------------------
LoadGameView = class(UIView)
M.LoadGameView = LoadGameView

function LoadGameView:init(params)
    self._players = assert(params.players)        
    
    LoadGameView.__super.init(self, params)
end

---
-- Criando um Objeto.
function LoadGameView:_createChildren()
    LoadGameView.__super._createChildren(self)
    local font = flower.getFont("fonts/SHOWG.TTF", nil, 18)
                      
    self.titleImage = NineImage("bg_main.png", flower.viewWidth, flower.viewHeight)    
    self:addChild(self.titleImage)
           
    self.titleLabel = Label("Selecione um perfil para carregar", nil, nil, font, 30)    
    self:addChild(self.titleLabel)
        
    self._slot1 = Button {
        text = "",        
        textColor = {1,1,1,1},        
        fontName = "SHOWG.TTF",
        normalTexture = "minigames/assets/button-normal.png",
        selectedTexture = "minigames/assets/button-selected.png",      
        parent = self,
        onClick = function(e)          
            self:dispatchEvent("initGame", e)
        end,        
    }
    
    self._slot2 = Button {
          text = "",        
          textColor = {1,1,1,1},        
          fontName = "SHOWG.TTF",
          normalTexture = "minigames/assets/button-normal.png",
          selectedTexture = "minigames/assets/button-selected.png",      
          parent = self,
          onClick = function(e)            
              self:dispatchEvent("initGame", e)
          end,        
    }
    
    self._slot3 = Button {
        text = "",        
        textColor = {1,1,1,1},        
        fontName = "SHOWG.TTF",
        normalTexture = "minigames/assets/button-normal.png",
        selectedTexture = "minigames/assets/button-selected.png",      
        parent = self,
        onClick = function(e)
            self:dispatchEvent("initGame", e)
        end,        
    }
    
    local slotEmpty = "Slot vazio"
    
    if (self._players[1] == nil) then
       self._slot1:setText(slotEmpty)
    else
       self._slot1:setText(self._players[1].name)
       self._slot1.player = self._players[1]
    end
    
    if (self._players[2] == nil) then
       self._slot2:setText(slotEmpty)
    else
       self._slot2:setText(self._players[2].name) 
    end
    if (self._players[3] == nil) then
       self._slot3:setText(slotEmpty)
    else
       self._slot3:setText(self._players[3].name)
    end
    
    
    
    self._backButton = ImageButton {                        
      normalTexture = "assets/back.png",
      selectedTexture = "assets/backHover.png",      
      onClick = function(e)
          self:dispatchEvent("back", e)
      end,      
      parent = self
    } 
end

function LoadGameView:setPlayers(players)
    self._players = players    
end

function LoadGameView:updateDisplay()
    LoadGameView.__super.updateDisplay(self)
    
    local vw, vh = flower.getViewSize()
    local mW = math.floor(vw / 2)
    local mH = math.floor(vh / 2)
    local sizeButtonW, sizeButtonH = mW, mH / 3      
    local posButtonX, posButtonY = mW - sizeButtonW / 2, mW - sizeButtonH / 2
    
    self._slot1:setSize(sizeButtonW, sizeButtonH)
    self._slot2:setSize(sizeButtonW, sizeButtonH)
    self._slot3:setSize(sizeButtonW, sizeButtonH)
    
    self._slot1:setPos(posButtonX, posButtonY)
    self._slot2:setPos(self._slot1:getLeft(), self._slot1:getBottom() + 20)    
    self._slot3:setPos(self._slot2:getLeft(), self._slot2:getBottom() + 20) 
    
    self._backButton:setPos(self.titleImage:getLeft(),self.titleImage:getBottom() - self._backButton:getHeight())
end


--------------------------------------------------------------------------------
-- @type MapControlView
--------------------------------------------------------------------------------
MapControlView = class(UIView)
M.MapControlView = MapControlView

MapControlView.JOYSTICK = nil
MapControlView.ENTER_BUTTON = nil
MapControlView.OPTION_BUTTON = nil
MapControlView.PROFILE_BUTTON = nil


function MapControlView:_createChildren()
    MapControlView.__super._createChildren(self)

    --JOYSTICK
    self.joystick = Joystick {
        stickMode = "digital",
        parent = self,        
        color = {0.6, 0.6, 0.6, 0.6},
        OnStickChanged = function(e)          
          self:dispatchEvent('OnStickChanged', e)
        end,
    }    
    --BUTTON ENTER
    self.enterButton = Button {
        size = {100, 50},
        color = {0.6, 0.6, 0.6, 0.6},
        text = "Enter",
        parent = self,
        onClick = function(e)
            self:dispatchEvent("enter")
        end,
    }    
    --BUTTON OPTION
    self.optionButton = ImageButton {
        pos = {self:getWidth()-43, 5},
        normalTexture = "skins/bt_option.png",
        selectedTexture = "skins/bt_option_selected.png",
        disabledTexture = "skins/bt_option.png",
        parent = self,
        onClick = function(e)
          self:dispatchEvent("buttonOption_Click")
        end,
    }
    --BUTTON PROFILE
    self.profileButton = ImageButton {
        pos = {self.optionButton:getLeft()-43, 5},
        normalTexture = "skins/bt_profile.png",
        selectedTexture = "skins/bt_profile_selected.png",
        disabledTexture = "skins/bt_profile.png",
        parent = self,
        onClick = function(e)
          self:dispatchEvent("buttonProfile_Click")
        end,
    }
    
    MapControlView.JOYSTICK = self.joystick    
    MapControlView.ENTER_BUTTON = self.enterButton
    MapControlView.OPTION_BUTTON = self.optionButton
    MapControlView.PROFILE_BUTTON = self.profileButton
end

function MapControlView:updateLayout()
    local vw, vh = flower.getViewSize()
    
    local joystick = MapControlView.JOYSTICK
    local enterButton = MapControlView.ENTER_BUTTON
    local optionButton = MapControlView.OPTION_BUTTON
    local profileButton = MapControlView.PROFILE_BUTTON         
        
    joystick:setPos(10, vh - joystick:getHeight() - 10)
    enterButton:setPos(vw - enterButton:getWidth() - 10, vh - enterButton:getHeight() - 10)
    
    optionButton:setPos(vw-43, 5)
    profileButton:setPos(optionButton:getLeft()-43, 5)
end

function MapControlView:updateDisplay()
    MapControlView.__super.updateDisplay(self)
    
    local vw, vh = flower.getViewSize()
    local joystick = self.joystick
    local enterButton = self.enterButton
    
    joystick:setPos(10, vh - joystick:getHeight() - 10)
    enterButton:setPos(vw - enterButton:getWidth() - 10, vh - enterButton:getHeight() - 10)
end

function MapControlView:getDirection()
    if InputMgr:keyIsDown(KeyCode.LEFT) then
        return "left"
    end
    if InputMgr:keyIsDown(KeyCode.UP) then
        return "up"
    end
    if InputMgr:keyIsDown(KeyCode.RIGHT) then
        return "right"
    end
    if InputMgr:keyIsDown(KeyCode.DOWN) then
        return "down"
    end
    return STICK_TO_DIR[self.joystick:getStickDirection()]
end

function MapControlView:reset()
    local joystick = MapControlView.JOYSTICK
    joystick:setCenterKnob()    
end

--------------------------------------------------------------------------------
-- @type MapPlayerInfo
--------------------------------------------------------------------------------
MapPlayerInfo = class(UIView)
M.MapPlayerInfo = MapPlayerInfo


function MapPlayerInfo:_createChildren()
    MapPlayerInfo.__super._createChildren(self)
    
end

function MapPlayerInfo:updateDisplay()
    MapPlayerInfo.__super.updateDisplay(self)    
end

function MapPlayerInfo:onUpdate()
   
end


--------------------------------------------------------------------------------
-- @type MenuControlView
-- 
--------------------------------------------------------------------------------
MenuControlView = class(UIView)
M.MenuControlView = MenuControlView

---
-- オブジェクトを生成します.
function MenuControlView:_createChildren()
    MenuControlView.__super._createChildren(self)

    self.backButton = Button {
        size = {100, 50},
        pos = {flower.viewWidth - 100 - 10, flower.viewHeight - 50 - 10},
        color = {0.6, 0.6, 0.6, 0.6},
        text = "Back",
        parent = self,
        onClick = function(e)
            self:dispatchEvent("back")
        end,
    }

end

-----
--
--  PROFILE MENU
--
-----
ProfileView = class(UIView)
M.ProfileView = ProfileView

---
-- I will create a child object.
function ProfileView:_createChildren()
    ProfileView.__super._createChildren(self)
                
    self.detailBox = ActorDetailBox {
        actor = {repositry:getActorById(1)},
        parent = self,
        size = {self:getWidth()/2,260},
        pos = {self:getWidth()/2-200, self:getHeight()/2-130},        
    }
    self.detailBox:addEventListener(Event.TOUCH_DOWN, self.onTouchDown, self)     
end

function ProfileView:onTouchDown(e)
    self:dispatchEvent("back", e.data)
end

-----
--
--  TALK VIEW
--
-----
TalkView = class(UIView)
M.TalkView = TalkView

function TalkView:init(params)
    self._actor = assert(params.actor)    
    self._talk = assert(params.talk)
    
    TalkView.__super.init(self, params)
end

---
-- I will create a child object.
function TalkView:_createChildren()
    TalkView.__super._createChildren(self)
       
    self.talkBox = TalkBox {
        actor = self._actor,
        talk = self._talk,
        parent = self,        
        size = {self:getWidth()/2,180},
        pos = {self:getWidth()/2-200, self:getHeight()/2-130},        
    }    
    
    self.talkBox:addEventListener("resposta", self.onResposta, self)       
end

function TalkView:onResposta(e)    
    e.data.talk = self._talk
    e.data.actor = self._actor
    self.talkBox:setVisible(false)
    self:dispatchEvent("close", e.data)    
end

function TalkView:setActor(actor)
    self._actor = actor
end

function TalkView:setTalk(talk)
    self._talk = talk
end


--------------------------------------------------------------------------------
-- @type MenuItemView
-- アイテムメニューのビュークラスです.
--------------------------------------------------------------------------------
MenuItemView = class(UIView)
M.MenuItemView = MenuItemView

---
-- 子オブジェクトを生成します.
function MenuItemView:_createChildren()
    MenuItemView.__super._createChildren(self)

    self.itemList = ItemListBox {
        pos = {0, 0},
        parent = self,
        onItemChanged = function(e)
            local data = e.data
            local text = data and data.item.description or ""
            self.itemMsgBox:setText(text)
        end,
        onItemEnter = function(e)
            self:dispatchEvent("enter", e.data)
        end,
    }

    self.itemMsgBox = widget.TextBox {
        size = {WIDGET_WIDTH, 80},
        pos = {0, self.itemList:getBottom()},
        parent = self,
    }
end


return M