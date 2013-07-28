----------------------------------------------------------------------------------------------------
-- ウィジェットクラスを定義するモジュールです.
-- ゲームに特化した部品を定義します.
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "hanappe/flower"
local widget = require "hanappe/extensions/widget"
local entities = require "libs/entities"
local display = require "libs/display"
local repositry = entities.repositry
local class = flower.class
local table = flower.table
local ClassFactory = flower.ClassFactory
local InputMgr = flower.InputMgr
local SceneMgr = flower.SceneMgr
local Group = flower.Group
local Label = flower.Label
local TextAlign = widget.TextAlign
local UIView = widget.UIView
local UIComponent = widget.UIComponent
local Joystick = widget.Joystick
local Button = widget.Button
local Panel = widget.Panel
local ListBox = widget.ListBox
local ListItem = widget.ListItem
local TextBox = widget.TextBox
local FaceImage = display.FaceImage
local ActorImage = display.ActorImage
-- classes
local ActorStatusBox
local ActorDetailBox
local AvatarInfoBox
--local ItemListBox
--local ItemListItem
--local SkillListBox
--local SkillListItem
--local MemberListBox
--local MemberListItem
--local InventoryListBox

-- ウィジェットの最大の横幅
local WIDGET_WIDTH = 400

--------------------------------------------------------------------------------
-- @type ActorDetailBox
--------------------------------------------------------------------------------
ActorDetailBox = class(Panel)
M.ActorDetailBox = ActorDetailBox

-- Label names
ActorDetailBox.STATUS_LABEL_NAMES = {
    "FORÇA",
    "SAÚDE",
    "INTELIGÊNCIA",    
    "VELOCIDADE",
}

-- Label names
ActorDetailBox.EQUIP_ICONS = {
    1,
    2,
    3,
    4,
}

---
-- 内部変数を初期化します.
function ActorDetailBox:_initInternal()
    ActorDetailBox.__super._initInternal(self)
    self._faceImage = nil
    self._statusNameLabels = {}
    self._statusValueLabels = {}
    self._skills = {}
    self._actor = nil         
end

---
-- 子オブジェクトを生成します.
function ActorDetailBox:_createChildren()
    ActorDetailBox.__super._createChildren(self)
    self:_createFaceImage()
    self:_createHeaderLabel()
    self:_createStatusLabel()
    self:_createSkillsLabel()
    self:setSize(WIDGET_WIDTH, 260)
end

---
-- フェイスイメージを生成します.
function ActorDetailBox:_createFaceImage()
    self._faceImage = FaceImage(1)    
    self._faceImage:setPos(10, 10)
    self:addChild(self._faceImage)
end

---
-- ヘッダーラベルを生成します.
function ActorDetailBox:_createHeaderLabel()
    self._headerLabel = Label("DUMMY", 130, 100, nil, 22)
    self._headerLabel:setPos(self._faceImage:getRight() + 10, 10)
    self:addChild(self._headerLabel)    
end

---
-- ステータスラベルを生成します.
function ActorDetailBox:_createStatusLabel()
    local offsetX, offsetY = self._faceImage:getLeft(), 5 + self._faceImage:getBottom()
    for i, name in ipairs(ActorDetailBox.STATUS_LABEL_NAMES) do
        local nameLabel = Label(name, 150, 30, nil, 18)
        nameLabel:setPos(offsetX, offsetY + (i - 1) * nameLabel:getHeight())

        local valueLabel = Label("", 50, 30, nil, 18)
        valueLabel:setPos(nameLabel:getRight(), offsetY + (i - 1) * nameLabel:getHeight())

        self:addChild(nameLabel)
        self:addChild(valueLabel)
        table.insert(self._statusNameLabels, nameLabel)
        table.insert(self._statusValueLabels, valueLabel)
    end
end


function ActorDetailBox:_createSkillsLabel()             
    self._skillsLabel = Label("Habilidades", 150, 30, nil, 22)
    self._skillsLabel:setPos(self._headerLabel:getRight() + 10,10)
    self:addChild(self._skillsLabel)         
end

---
-- 表示を更新します.
function ActorDetailBox:updateDisplay()
    ActorDetailBox.__super.updateDisplay(self)
    self:updateHeaderLabel()
    self:updateStatusLabel()
    self:updateSkillsLabel()
end

---
-- ヘッダーの表示を更新します.
function ActorDetailBox:updateHeaderLabel()
    if not self._actor then
        return
    end
    local a = self._actor
    local text = string.format("%s\nLEVEL:%d\nXP:%d", a.name, a.level, a.exp)
    self._headerLabel:setString(text)
end

---
-- ステータスラベルの表示を更新します.
function ActorDetailBox:updateStatusLabel()
    if not self._actor then
        return
    end
    local actor = self._actor
    self._statusValueLabels[1]:setString(tostring(actor.str))
    self._statusValueLabels[2]:setString(tostring(actor.vit))
    self._statusValueLabels[3]:setString(tostring(actor.int))    
    self._statusValueLabels[4]:setString(tostring(actor.spd))
end

function ActorDetailBox:updateSkillsLabel()
    if not self._actor then
        return
    end    
    local actor = self._actor
    local skills = actor:getSkills()
    
    local offsetX, offsetY = self._skillsLabel:getLeft(), 5 + self._skillsLabel:getBottom()
    for i, skill in ipairs(skills) do
        if table.indexOf(self._skills,skill) == 0 then                 
            local nameLabel = Label(skill.name, 150, 30, nil, 15)
            nameLabel:setPos(offsetX, offsetY + (i - 1) * nameLabel:getHeight())                    
            self:addChild(nameLabel)            
            table.insert(self._skills,skill)
        end
    end
    
end

---
-- 表示対象のアクターを設定します.
-- @param actor アクター
function ActorDetailBox:setActor(actor)
    self._actor = actor
    self:updateDisplay()
end

--------------------------------------------------------------------------------
-- @type ActorStatusBox
-- アクターの簡易的なステータスを表示するボックスです.
--------------------------------------------------------------------------------
ActorStatusBox = class(Panel)
M.ActorStatusBox = ActorStatusBox

---
-- コンストラクタ
-- @param params パラメータ
function ActorStatusBox:init(params)
    self._actor = params.actor
    params.size = {250, 105}

    ActorStatusBox.__super.init(self, params)
end

---
-- 子オブジェクトを生成します.
function ActorStatusBox:_createChildren()
    ActorStatusBox.__super._createChildren(self)

    self._faceImage = FaceImage(1)
    self._faceImage:setPos(5, 5)
    self:addChild(self._faceImage)
    
    self._nameValueLabel = Label(self._actor.name, 130, 24, nil, 18)       
    self._nameValueLabel:setPos(self._faceImage:getRight()+5,5)
    self:addChild(self._nameValueLabel)

    self._lvlNameLabel = Label("LVL", 30, 20, nil, 16)       
    self._lvlNameLabel:setPos(self._faceImage:getRight()+5,self._nameValueLabel:getBottom()+5)    
    self._lvlValueLabel = Label(tostring(self._actor.level), 100, 20, nil, 16)       
    self._lvlValueLabel:setPos(self._lvlNameLabel:getRight()+5,self._nameValueLabel:getBottom()+5)
    self:addChild(self._lvlNameLabel)
    self:addChild(self._lvlValueLabel)
    
    self._expNameLabel = Label("EXP", 30, 20, nil, 16)       
    self._expNameLabel:setPos(self._faceImage:getRight()+5,self._lvlNameLabel:getBottom()+5)    
    self._expValueLabel = Label(tostring(self._actor.exp), 100, 20, nil, 16)       
    self._expValueLabel:setPos(self._expNameLabel:getRight()+5,self._lvlNameLabel:getBottom()+5)
    self:addChild(self._expNameLabel)
    self:addChild(self._expValueLabel)
    
end
---
-- 表示対象のアクターを設定します.
function ActorStatusBox:setActor(actor)
    self._actor = actor   
end


--------------------------------------------------------------------------------
-- @type TalkBox
-- アクターの簡易的なステータスを表示するボックスです.
--------------------------------------------------------------------------------
TalkBox = class(Panel)
M.TalkBox = TalkBox

---
-- コンストラクタ
-- @param params パラメータ
function TalkBox:init(params)
    self._actorA = params.actorA
    self._actorB = params.actorB        
    TalkBox.__super.init(self, params)
end

---
-- 子オブジェクトを生成します.
function TalkBox:_createChildren()
    TalkBox.__super._createChildren(self)

    self._faceImage = FaceImage(2)
    self._faceImage:setPos(5, 5)
    self:addChild(self._faceImage)       
    
    self._talk = self._actorB:getTalkById(1)    
    self._answer = self._talk.answer
    
    self._msgBox = widget.TextBox {
        size = {self._faceImage:getWidth(), 100},
        pos = {self._faceImage:getRight()+5, 5},
        text = self._answer,
        parent = self,
    }        
    
    self._responseListBox = ListBox {        
        rowCount = 1,
        columnCount = 2,
        pos = {5, self._faceImage:getBottom()+5},
        parent = self,
        labelField = "label",
        listData = {self._talk.answers},        
        onItemChanged = function(e)            
            self:dispatchEvent("resposta",e)
        end
    }
    
end

function TalkBox:updateDisplay()
    TalkBox.__super.updateDisplay(self)       
    local width,height = self:getSize()
    
    self._msgBox:setSize(width-self._faceImage:getWidth()-15,100)
    self._responseListBox:setSize(width-10,height-110)
end

function TalkBox:newTalk()
    local talk
    return talk
end

---
-- 表示対象のアクターを設定します.
function TalkBox:setActorA(actorA)
    self._actorA = actorA   
end

function TalkBox:setActorB(actorB)
    self._actorB = actorB   
end

















--------------------------------------------------------------------------------
-- @type ItemListBox
-- アイテムを表示するリストボックスです.
--------------------------------------------------------------------------------
ItemListBox = class(ListBox)
M.ItemListBox = ItemListBox

---
-- コンストラクタ
-- @param params パラメータ
function ItemListBox:init(params)
    params.listData = {repositry:getBagItems()}
    params.width = flower.viewWidth
    params.rowCount = 6
    params.labelField = "itemName"
    params.listItemFactory = ClassFactory(ItemListItem)

    ItemListBox.__super.init(self, params)
end

--------------------------------------------------------------------------------
-- @type ItemListItem
-- アイテム名とアイテム数をセットで表示するリストアイテムです.
--------------------------------------------------------------------------------
ItemListItem = class(ListItem)
M.ItemListItem = ItemListItem

ItemListItem._COUNT_LABEL_SUFFIX = "個"

---
-- コンストラクタ
-- @param params パラメータ
function ItemListItem:init(params)
    ItemListItem.__super.init(self, params)
end

---
-- 子オブジェクトを生成します.
function ItemListItem:_createChildren()
    ItemListItem.__super._createChildren(self)

    self._countLabel = Label("0")
    self:addChild(self._countLabel)
end

---
-- 表示を更新します.
function ItemListItem:updateDisplay()
    ItemListItem.__super.updateDisplay(self)

    local label = self._countLabel
    local xMin, yMin, xMax, yMax = self._backgroundImage:getContentRect()
    local textWidth, textHeight = xMax - xMin, yMax - yMin
    self._textLabel:setSize(textWidth - 60, textHeight)
    label:setSize(60, textHeight)
    label:setPos(self._textLabel:getRight(), self._textLabel:getTop())
    label:setString(tostring(self:getItemCount()) .. ItemListItem._COUNT_LABEL_SUFFIX)
    label:setTextSize(self:getTextSize())
    label:setColor(self:getTextColor())
    label:setAlignment(TextAlign.right)
    label:setFont(self:getFont())
end

---
-- データを設定します.データ設定時、件数も更新します.
function ItemListItem:setData(data, dataIndex)
    ItemListItem.__super.setData(self, data, dataIndex)
    self._countLabel:setString(tostring(self:getItemCount()) .. ItemListItem._COUNT_LABEL_SUFFIX)
end

---
-- アイテム数を返します.
-- @return アイテム数
function ItemListItem:getItemCount()
    if self._data then
        return self._data.itemCount or 0
    end
    return 0
end

---
-- サイズ変更時にイベントハンドラです.
-- @param e Touch Event
function ItemListItem:onResize(e)
    self:updateDisplay()
end

--------------------------------------------------------------------------------
-- @type SkillListBox
-- アクターが保持するスキルを表示するリストボックスです.
--------------------------------------------------------------------------------
SkillListBox = class(ListBox)
M.SkillListBox = SkillListBox

---
-- コンストラクタ
-- @param params
function SkillListBox:init(params)
    local actor = params.actor
    params = params
    params.listData = {actor:getSkills()}
    params.width = WIDGET_WIDTH
    params.rowCount = 6
    params.labelField = "name"

    SkillListBox.__super.init(self, params)
end

---
-- アクターを設定します.
-- @param actor アクター
function SkillListBox:setActor(actor)
    self._actor = actor
    self:setListData(self._actor:getSkills())
end

--------------------------------------------------------------------------------
-- @type MemberListBox
-- プレイヤーメンバーを表示するリストボックスです.
--------------------------------------------------------------------------------
MemberListBox = class(ListBox)
M.MemberListBox = MemberListBox

---
-- コンストラクタ.
-- @param params パラメータ
function MemberListBox:init(params)
    params = params or {}
    params.listData = {repositry:getMembers()}
    params.width = 200
    params.rowCount = 3
    params.columnCount = 1
    params.labelField = "name"
    params.listItemFactory = ClassFactory(MemberListItem)

    MemberListBox.__super.init(self, params)
end

--------------------------------------------------------------------------------
-- @type MemberListItem
-- メンバーの名前とアイコンを表示するリストアイテムです.
--------------------------------------------------------------------------------
MemberListItem = class(ListItem)
M.MemberListItem = MemberListItem

---
-- コンストラクタ.
-- @param params パラメータ
function MemberListItem:init(params)
    MemberListItem.__super.init(self, params)
end

---
-- 子オブジェクトを生成します.
function MemberListItem:_createChildren()
    MemberListItem.__super._createChildren(self)

    self._actorImage = ActorImage("actor1.png") -- Dummy
    self._actorImage:setIndex(2)
    self:addChild(self._actorImage)
end

---
-- 表示を更新します.
function MemberListItem:updateDisplay()
    MemberListItem.__super.updateDisplay(self)
    
    local data = self._data or {id = 1}
    local xMin, yMin, xMax, yMax = self._backgroundImage:getContentRect()
    local textWidth, textHeight = xMax - xMin - self._actorImage:getWidth(), yMax - yMin

    self._actorImage:setTexture("actor" .. data.id .. ".png")
    self._actorImage:setPos(xMin, (self:getHeight() - self._actorImage:getHeight()) / 2)

    self._textLabel:setSize(textWidth - 60, textHeight)
    self._textLabel:setPos(self._actorImage:getRight() + 5, yMin)
end

---
-- データを設定します.データ設定時、表示全体を更新します.
function MemberListItem:setData(data, dataIndex)
    MemberListItem.__super.setData(self, data, dataIndex)
    self:updateDisplay()
end

---
-- サイズ変更時にイベントハンドラです.
-- @param e Touch Event
function MemberListItem:onResize(e)
    self:updateDisplay()
end

--------------------------------------------------------------------------------
-- @type AvatarView
-- 
--------------------------------------------------------------------------------
AvatarInfoBox = class(UIView)
M.AvatarInfoBox = AvatarInfoBox

function AvatarInfoBox:init(params)            
    AvatarInfoBox.__super.init(self, params)    
end

function AvatarInfoBox:_createChildren()    
    AvatarInfoBox.__super._createChildren(self)   
    
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

function AvatarInfoBox:updateDisplay()
    AvatarInfoBox.__super.updateDisplay(self)   
    
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

function AvatarInfoBox:setPlayer(player)
    self._player = player
end


return M