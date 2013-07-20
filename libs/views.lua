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
--local widgets = require "libs/widgets"
--local entities = require "libs/entities"
--local repositry = entities.repositry
local InputMgr = flower.InputMgr
local class = flower.class
local table = flower.table
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
--local ActorStatusBox = widgets.ActorStatusBox
--local ActorDetailBox = widgets.ActorDetailBox
--local ItemListBox = widgets.ItemListBox
--local SkillListBox = widgets.SkillListBox
--local MemberListBox = widgets.MemberListBox

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

--------------------------------------------------------------------------------
-- @type MapPlayerInfo
--------------------------------------------------------------------------------
MapPlayerInfo = class(UIView)
M.MapPlayerInfo = MapPlayerInfo

MapPlayerInfo.NAME = "null"
MapPlayerInfo.XP = 0 

function MapPlayerInfo:_createChildren()
    MapPlayerInfo.__super._createChildren(self)
    
    self.playerPanel = widget.Panel {
        size = {250, 90},
        pos = {5, 5},
        parent = self,
        backgroundTexture = "skins/panel_playerinfo.png",
        backgroundVisible = "skins/panel_playerinfo.png"
    }
    
    -- AVATAR IMAGE
    self.avatarImage = flower.NineImage("avatars/avatar5.png")
    self.avatarImage:setPos(0,0)
    self.avatarImage:setSize(80,85)
    self.playerPanel:addChild(self.avatarImage)  
    
    self.lbNome = flower.Label(MapPlayerInfo.NAME, 100, 30, "arial-rounded.ttf")    
    self.lbNome:setPos(80,5)
    self.playerPanel:addChild(self.lbNome)
    
    self.labelLVL = flower.Label("LVL", 100, 30, "arial-rounded.ttf",14)
    self.labelLVL:setPos(80,35)
    self.playerPanel:addChild(self.labelLVL)    
      
    self.lbLVL = flower.Label(tostring(MapPlayerInfo.XP), 100, 30, "arial-rounded.ttf",18)    
    self.lbLVL:setPos(112,33)
    self.playerPanel:addChild(self.lbLVL)    

    self.barXP = flower.NineImage("skins/barXp.png")
    self.barXP:setPos(80,55)
    self.barXP:setSize(165,26)
    self.playerPanel:addChild(self.barXP)  

    self.barXPbar = flower.NineImage("skins/barXpbar.png")
    self.barXPbar:setPos(124,57)
    self.barXPbar:setSize(80,22)
    self.playerPanel:addChild(self.barXPbar)
end

function MapPlayerInfo:updateDisplay()
    MapPlayerInfo.__super.updateDisplay(self)    
    local vw, vh = flower.getViewSize()    
end

function MapPlayerInfo:setName(name)
  MapPlayerInfo.NAME = name
  
end
function MapPlayerInfo:setXP(xp)
  MapPlayerInfo.XP = xp  
end  

function MapPlayerInfo:onUpdate()
    self.lbNome:setString(MapPlayerInfo.NAME)
    self.lbLVL:setString(tostring(MapPlayerInfo.XP))
end


return M