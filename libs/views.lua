----------------------------------------------------------------------------------------------------
-- ビュークラスを定義するモジュールです.
-- 
-- ビューとは、複数のウィジェットで構成される部品の集まりです.
-- 
-- 
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
local ImageButton = widget.ImageButton
local NineImage = flower.NineImage
local UIView = widget.UIView
local Joystick = widget.Joystick
local Button = widget.Button
local Panel = widget.Panel
local ListBox = widget.ListBox
local ListItem = widget.ListItem
local TextBox = widget.TextBox
local ActorStatusBox = widgets.ActorStatusBox
local ActorDetailBox = widgets.ActorDetailBox
--local ItemListBox = widgets.ItemListBox
local SkillListBox = widgets.SkillListBox
local MemberListBox = widgets.MemberListBox

-- classes
local TitleMenuView

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
-- タイトルメニューを表示するためのビュークラスです.
--------------------------------------------------------------------------------
TitleMenuView = class(UIView)
M.TitleMenuView = TitleMenuView

---
-- オブジェクトを生成します.
function TitleMenuView:_createChildren()
    TitleMenuView.__super._createChildren(self)
    
    self.titleImage = NineImage("title.png", flower.viewWidth, flower.viewHeight)    
    self:addChild(self.titleImage)
    
    self.newButton = Button {
        text = "Novo Jogo",
        size = {200, 50},
        pos = {math.floor(flower.viewWidth / 2 - 100), math.floor(flower.viewHeight / 2)},
        parent = self,
        onClick = function(e)
            self:dispatchEvent("newGame")
        end,
    }
    self.newButton:setFontName('Livingst.ttf')
    self.loadButton = Button {
        text = "Carregar Jogo",
        size = {200, 50},
        pos = {self.newButton:getLeft(), self.newButton:getBottom() + 10},
        parent = self,
        onClick = function(e)
            self:dispatchEvent("loadGame")
        end,
    }
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
    self.statusBox = ActorStatusBox {
        parent = self,
        actor = repositry:getActorById(1),
        pos = {5,5}
    }
end

function MapPlayerInfo:updateDisplay()
    MapPlayerInfo.__super.updateDisplay(self)    
end

function MapPlayerInfo:onUpdate()
   
end


--------------------------------------------------------------------------------
-- @type MenuControlView
-- メニューシーンをコントロールするためのビュークラスです.
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
    self._actorA = params.actorA    
    self._actorB = params.actorB
    
    TalkView.__super.init(self, params)
end

---
-- I will create a child object.
function TalkView:_createChildren()
    TalkView.__super._createChildren(self)
       
    self.talkBox = TalkBox {
        actorA = self._actorA,
        actorB = self._actorB,
        parent = self,        
        size = {self:getWidth()/2,180},
        pos = {self:getWidth()/2-200, self:getHeight()/2-130},        
    }    
    
    self.talkBox:addEventListener("resposta", self.onResposta, self)
    self.talkBox:addEventListener(Event.TOUCH_DOWN, self.onTouchDown, self)     
end

function TalkView:onResposta(e)
    print('respondeu')
end

function TalkView:onTouchDown(e)
    self:dispatchEvent("back", e.data)
end

function TalkView:setActorA(actorA)
    self._actorA = actorA
end

function TalkView:setActorB(actorB)
    self._actorB = actorB
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

--[[--------------------------------------------------------------------------------
-- @type MenuMainView
-- It is the view class in the main menu.
--------------------------------------------------------------------------------
MenuMainView = class(UIView)
M.MenuMainView = MenuMainView

---
-- I will create a child object.
function MenuMainView:_createChildren()
    MenuMainView.__super._createChildren(self)

    self.menuList = ListBox {
        width = self:getWidth(),
        pos = {0, 0},
        rowCount = 2,
        columnCount = 3,
        parent = self,
        labelField = "title",
        listData = {repositry:getMenus()},
        onItemChanged = function(e)
            local data = e.data
            local text = data and data.description or ""
            self.menuMsgBox:setText(text)
        end,
        onItemEnter = function(e)
            self:dispatchEvent("enter", e.data)
        end,
    }

    self.menuMsgBox = widget.TextBox {
        size = {self:getWidth(), 40},
        pos = {0, self.menuList:getBottom()},
        parent = self,
    }

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

--------------------------------------------------------------------------------
-- @type MenuStatusView
-- ステータスメニューのビュークラスです.
--------------------------------------------------------------------------------
MenuStatusView = class(UIView)
M.MenuStatusView = MenuStatusView

---
-- 内部変数の初期化処理です.
function MenuStatusView:_initInternal()
    MenuStatusView.__super._initInternal(self)
    self._statusBoxList = {}
end

---
-- 子オブジェクトの生成処理です.
function MenuStatusView:_createChildren()
    MenuStatusView.__super._createChildren(self)

    self.memberList = MemberListBox {
        pos = {0, 0},
        parent = self,
        selectedIndex = 0,
        onItemChanged = function(e)
            local data = e.data
            self.detailBox:setActor(data)
        end,
    }

    self.detailBox = ActorDetailBox {
        actor = {repositry:getActorById(1)},
        parent = self,
        pos = {0, self.memberList:getBottom() + 5}
    }
end

--------------------------------------------------------------------------------
-- @type MenuSettingView
-- 設定メニューのビュークラスです.
-- システムの設定を変更します.
--------------------------------------------------------------------------------
MenuSettingView = class(UIView)
M.MenuSettingView = MenuSettingView

function MenuSettingView:_initInternal()
    MenuSettingView.__super._initInternal(self)
end

function MenuSettingView:_createChildren()
    MenuStatusView.__super._createChildren(self)
end

--------------------------------------------------------------------------------
-- @type MenuSkillView
-- スキルメニューのビュークラスです.
--------------------------------------------------------------------------------
MenuSkillView = class(UIView)
M.MenuSkillView = MenuSkillView

---
-- 子オブジェクトを生成します.
function MenuSkillView:_createChildren()
    MenuSkillView.__super._createChildren(self)
    
    self.memberList = MemberListBox {
        pos = {0, 0},
        parent = self,
        selectedIndex = 0,
        onItemChanged = function(e)
            local data = e.data
            self.skillList:setActor(data)
        end,
    }

    self.skillList = SkillListBox {
        pos = {0, self.memberList:getBottom() + 5},
        actor = repositry:getActorById(1),
        parent = self,
        onItemChanged = function(e)
            local data = e.data
            local text = data and data.descripsion or ""
            self.msgBox:setText(text)
        end,
        onItemEnter = function(e)
            self:dispatchEvent("enter", e.data)
        end,
    }

    self.msgBox = widget.TextBox {
        size = {WIDGET_WIDTH, 80},
        pos = {0, self.skillList:getBottom()},
        parent = self,
    }
end
]]

return M