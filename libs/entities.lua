----------------------------------------------------------------------------------------------------
-- ゲームのエンティティを定義するモジュールです.
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "hanappe/flower"
--local logger = require "libs/logger"
local class = flower.class
local table = flower.table
local EventDispatcher = flower.EventDispatcher

-- classes
local Entity
local EntityPool
local EntityRepositry
local EntityWorld
local EntitySystem

local Skill
local Item
local ItemType
local Effect
local Menu
local Message
local Actor
local Player
local Enemy
local Team
local Bag
local BagItem
local Talk

-- variables
local entityPool
local repositry
local world

---
-- モジュールの初期化処理を行います.
function M.initialize()
    repositry = EntityRepositry()
    entityPool = EntityPool()
    entityPool:initEntities()

    M.repositry = repositry
end

--------------------------------------------------------------------------------
-- @type Entity
-- エンティティの共通的な振る舞いを定義するクラスです.
--------------------------------------------------------------------------------
Entity = class(EventDispatcher)
M.Entity = Entity

function Entity:init()
    Entity.__super.init(self)
end

---
-- データからエンティティにプロパティを読み込みます.
-- デフォルト実装は、単なるコピーです.
function Entity:loadData(data)
    table.copy(data, self)
end

---
-- エンティティからデータにプロパティを保存します.
-- デフォルト実装は単なるコピーです.
function Entity:saveData()
    local data = table.copy(self)
    data.__index = nil
    data.__class = nil
    return data
end

---
-- オブジェクトをコピーします.
-- @return オブジェクト
function Entity:clone()
    local obj = self.__class()
    table.copy(self, obj)
    return obj
end

--------------------------------------------------------------------------------
-- @type EntityPool
-- エンティティをメモリ上にプールする為のクラスです.
--------------------------------------------------------------------------------
EntityPool = class()
M.EntityPool = EntityPool

---
-- コンストラクタ
function EntityPool:init()
end

---
-- エンティティを初期化します.
function EntityPool:initEntities()
    self.skills = self:createEntities(Skill, dofile("data/skill_data.lua"))
    self.items = self:createEntities(Item, dofile("data/item_data.lua"))
    self.effects = self:createEntities(Effect, dofile("data/effect_data.lua"))
    self.menus = self:createEntities(Menu, dofile("data/menu_data.lua"))
    self.actors = self:createEntities(Actor, dofile("data/actor_data.lua"))
    self.enemies = self:createEntities(Enemy, dofile("data/enemy_data.lua"))
    self.teams = self:createEntities(Team, dofile("data/team_data.lua"))
    self.bagItems = self:createEntities(BagItem, dofile("data/bag_data.lua"))
    self.players = self:createEntities(Player, dofile("data/player_data.lua"))
    --self.talk = self:createEntities(Talk, dofile("data/talk_data.lua"))
    self.bag = Bag(self.bagItems)
end

---
-- セーブしていたエンティティを読み込みます.
function EntityPool:loadEntities(saveId)
    self.actors = self:createEntities(Actor, dofile("save" .. saveId .. "/actor_data.lua"))
    self.teams = self:createEntities(Actor, dofile("save" .. saveId .. "/team_data.lua"))
    self.bagItems = self:createEntities(Actor, dofile("save" .. saveId .. "/bag_data.lua"))
    self.bag = Bag(self.bagItems)
end

---
-- メモリ上のエンティティを保存します.
function EntityPool:saveEntities(saveId)
    
end

---
-- 指定したエンティティクラスを作成してデータをロードして返します.
-- @param clazz エンティティのクラス
-- @param entityDataList エンティティデータリスト
function EntityPool:createEntities(clazz, entityDataList)
    local entities = {}
    for i, data in ipairs(entityDataList) do
        local entity = clazz()
        entity:loadData(data)
        table.insertElement(entities, entity)
    end
    return entities
end

--------------------------------------------------------------------------------
-- @type EntityRepositry
-- エンティティにアクセスするリポジトリクラスです.
--------------------------------------------------------------------------------
EntityRepositry = class()
M.EntityRepositry = EntityRepositry

---
-- コンストラクタです.
function EntityRepositry:init()
end

---
-- 指定したエンティティリストについて、IDが一致するエンティティを返します.
-- @return IDが一致するエンティティ
function EntityRepositry:getEntityById(entities, id)
    assert(entities)
    assert(id)
    for i, entity in ipairs(entities) do
        if entity.id == id then
            return entity
        end
    end
end

---
-- 全てのアクターリストを返します.
-- @return アクターリスト
function EntityRepositry:getActors()
    return entityPool.actors
end

---
-- 指定したIDに一致するアクターを返します.
-- @return アクター
function EntityRepositry:getActorById(id)
    return self:getEntityById(entityPool.actors, id)
end

---
-- プレイヤーのチームに登録されたメンバーリストを返します.
-- @param メンバーリスト
function EntityRepositry:getMembers()
    local team = self:getEntityById(entityPool.teams, 1)
    return team.members
end

---
-- プレイヤーを返します.
-- TODO:適当なので修正が必要
function EntityRepositry:getPlayers()
    return entityPool.players
end

function EntityRepositry:getPlayerById(id)
    return self:getEntityById(entityPool.players, id)
end

function EntityRepositry:savePlayer(player)
    local actors = {}
    for i, actor in ipairs(entityPool.actors) do
        table.insertElement(actors, actor:saveData())
    end
    
   
    file = io.open ( "teste.lua", 'wb' )
    --player = self:getPlayerById(1)
    --self:savee("return",actors)
    self:save(entityPool.players,"teste.lua")
end

function EntityRepositry:savee(name,object)
  local type=type
	local tostring=tostring
	
	file:write(name.."\t{" .. "\n")

  local function thatkey(k)
		if type(k)=="number" then		
			return ''
		end
		return k
	end
	local function key_number(k,v)
		if type(k)=="number" then
			return "\t"
		end
		return "\t[\"" .. k .. "\"] = "
	end 

	for k,v in pairs(object) do  
      
      local the_type = type(v)      
      local old_k = k
      local k = thatkey(k)
      local k_string = key_number(old_k,v)
      
      if the_type == "string" then
          file:write(v)
      elseif the_type == "table" then
          self:savee(k, v, "\t")    
      elseif the_type == "number" then
          file:write('\t' .. k ..' = ' .. tostring(v))
      end
      
      
      if next(object,old_k) then file:write(",\n") else file:write("") end
      
	end
	
	file:write("\t\n".."}")
end

function exportstring( s )
      return string.format("%q", s)
end
function EntityRepositry:save(tbl,filename)
   local charS,charE = "   ","\n"
      local file,err = io.open( filename, "wb" )
      if err then return err end

      -- initiate variables for save procedure
      local tables,lookup = { tbl },{ [tbl] = 1 }
      file:write( "return {"..charE )

      for idx,t in ipairs( tables ) do
         file:write( "-- Table: {"..idx.."}"..charE )
         file:write( "{"..charE )
         local thandled = {}

         for i,v in ipairs( t ) do
            thandled[i] = true
            local stype = type( v )
            -- only handle value
            if stype == "table" then
               if not lookup[v] then
                  table.insert( tables, v )
                  lookup[v] = #tables
               end
               file:write( charS.."{"..lookup[v].."},"..charE )
            elseif stype == "string" then
               file:write(  charS..exportstring( v )..","..charE )
            elseif stype == "number" then
               file:write(  charS..tostring( v )..","..charE )
            end
         end

         for i,v in pairs( t ) do
            -- escape handled values
            if (not thandled[i]) then
            
               local str = ""
               local stype = type( i )
               -- handle index
               if stype == "table" then
                  if not lookup[i] then
                     table.insert( tables,i )
                     lookup[i] = #tables
                  end
                  str = charS.."[{"..lookup[i].."}]="
               elseif stype == "string" then
                  str = charS.."["..exportstring( i ).."]="
               elseif stype == "number" then
                  str = charS.."["..tostring( i ).."]="
               end
            
               if str ~= "" then
                  stype = type( v )
                  -- handle value
                  if stype == "table" then
                     if not lookup[v] then
                        table.insert( tables,v )
                        lookup[v] = #tables
                     end
                     file:write( str.."{"..lookup[v].."},"..charE )
                  elseif stype == "string" then
                     file:write( str..exportstring( v )..","..charE )
                  elseif stype == "number" then
                     file:write( str..tostring( v )..","..charE )
                  end
               end
            end
         end
         file:write( "},"..charE )
      end
      file:write( "}" )
      file:close()
end

---
-- 全てのアイテムリストを返します.
-- @return アイテムリスト
function EntityRepositry:getItems()
    return entityPool.items
end

---
-- 指定したIDに一致するアイテムを返します.
-- @return アイテム
function EntityRepositry:getItemById(id)
    return self:getEntityById(entityPool.items, id)
end

---
-- 全てのスキルリストを返します.
-- @return スキルリスト
function EntityRepositry:getSkills()
    return entityPool.skills
end

---
-- 指定したIDに一致するスキルを返します.
-- @return スキル
function EntityRepositry:getSkillById(id)
    return self:getEntityById(entityPool.skills, id)
end

---
-- 全てのエフェクトリストを返します.
-- @return エフェクトリスト
function EntityRepositry:getEffects()
    return entityPool.effects
end

---
-- 指定したIDに一致するエフェクトを返します.
-- @return エフェクト
function EntityRepositry:getEffectById(id)
    return self:getEntityById(entityPool.effects, id)
end

---
-- プレイヤーが保持するバッグを返します.
-- @return バッグ
function EntityRepositry:getBag()
    return entityPool.bag
end

---
-- バッグアイテムリストを返します.
-- @return バッグアイテムリスト
function EntityRepositry:getBagItems()
    return entityPool.bagItems
end

---
-- メニューリストを返します.
-- @return メニューリスト
function EntityRepositry:getMenus()
    return entityPool.menus
end

---
-- 指定したIDと同一のエネミーを作成して返します.
-- @param id エネミーID
-- @return エネミー
function EntityRepositry:createEnemy(id)
    local enemy = self:getEntityById(entityPool.enemies, id)
    return enemy:clone()
end

--------------------------------------------------------------------------------
-- @type Item
-- アイテムを定義するエンティティです.
--------------------------------------------------------------------------------
Item = class(Entity)
M.Item = Item

---
-- コンストラクタ
function Item:init()
    self.id = 0
    self.name = nil
    self.type = nil
    self.description = nil
    self.equipType = 0
    self.atk = 0
    self.def = 0
end

---
-- アイテムの効果を発揮します.
function Item:doEffectItem(actor)

end

function Item:doRecoveryItem(actor)

end

--------------------------------------------------------------------------------
-- @type ItemType
-- アイテム区分を定義するエンティティです.
--------------------------------------------------------------------------------
ItemType = class(Entity)
M.ItemType = ItemType

--- 回復アイテム
ItemType.RECOVERY = 1

--- 装備アイテム
ItemType.EQUIP = 2

---
-- コンストラクタ
function ItemType:init()
    self.id = 0
    self.name = nil
    self.description = nil
end

--------------------------------------------------------------------------------
-- @type Skill
-- スキルを定義するエンティティです.
--------------------------------------------------------------------------------
Skill = class(Entity)
M.Skill = Skill

function Skill:init()
    self.id = 0
    self.name = nil
    self.descripsion = nil
    self.effectId = 0
    self.useMp = 0
    self.atkPoint = 0
end

--------------------------------------------------------------------------------
-- @type Effect
-- スキルを定義するエンティティです.
--------------------------------------------------------------------------------
Effect = class(Entity)
M.Effect = Effect

function Effect:init()
    self.id = 0
    self.name = nil
    self.texture = nil
    self.tileSize = nil
    self.effectData = nil
end

--------------------------------------------------------------------------------
-- @type Menu
-- メインメニューから起動するメニューを表すエンティティクラスです.
--------------------------------------------------------------------------------
Menu = class(Entity)
M.Menu = Menu

function Menu:init()
    self.id = 0
    self.title = nil
    self.description = nil
    self.sceneName = nil
    self.sceneAnimation = "change"
end

--------------------------------------------------------------------------------
-- @type Bag
-- バッグを表すエンティティです.
-- アイテムを追加、削除する機能を有します.
--------------------------------------------------------------------------------
Bag = class(Entity)
M.Bag = Bag

---
-- コンストラクタ
-- @param bagItems バッグアイテムリスト
function Bag:init(bagItems)
    self.bagItems = assert(bagItems, "bagItems is required.")
end

---
-- バッグにアイテムを追加します.
-- @param item アイテム
function Bag:addItem(item)
    local bagItem = self:getBagItemById(item.id)
    if bagItem then
        bagItem.itemCount = bagItem.itemCount + 1
    else
        table.insertElement(self.bagItems, bagItem)
    end
end

---
-- バッグからアイテムを削除します.
-- @param item アイテム
function Bag:removeItem(item)
    local bagItem = self:getBagItemById(item.id)
    if bagItem then
        bagItem.itemCount = bagItem.itemCount - 1
        if bagItem.itemCount <= 0 then
            table.removeElement(self.bagItems, bagItem)
        end
    end
end

---
-- バッグにあるアイテムを検索して返します.
-- @param itemId アイテムID
-- @return バッグアイテム
function Bag:getBagItemById(itemId)
    for i, bagItem in ipairs() do
        if bagItem.item.id == itemId then
            return bagItem
        end
    end
end

---
-- バッグアイテムリストを返します.
-- @return バッグアイテムリスト
function Bag:getBagItems()
    return self.bagItems
end

--------------------------------------------------------------------------------
-- @type BagItem
-- バッグの中にあるアイテムを表現するエンティティです.
--------------------------------------------------------------------------------
BagItem = class(Entity)
M.BagItem = BagItem

---
-- コンストラクタ
-- @param item (option)アイテム
function BagItem:init(item)
    self.item = item
    self.itemName = item and item.name
    self.itemCount = item and 1 or 0
    self.itemEquipCount = 0
end

---
-- データを読み込みます.
-- @param data バッグデータ
function BagItem:loadData(data)
    self.item = assert(repositry:getItemById(data.itemId), "Not found item!")
    self.itemName = self.item.name
    self.itemCount = data.itemCount
    self.itemEquipCount = data.itemEquipCount
end

--------------------------------------------------------------------------------
-- @type Team
-- プレイヤーやエネミーの集合体を表すチームエンティティです.
--------------------------------------------------------------------------------
Team = class(Entity)
M.Team = Team

function Team:init()
    self.id = nil
    self.members = {}
end

---
-- データを読み込みます.
-- @param data バッグデータ
function Team:loadData(data)
    self.id = data.id
    self.members = {}
    for i, memberId in ipairs(data.members) do
        table.insert(self.members, repositry:getActorById(memberId))
    end
end

--------------------------------------------------------------------------------
-- @type Talk
-- 
-- 
--------------------------------------------------------------------------------
Talk = class(Entity)
M.Talk = Talk

function Talk:init()    
    self.id = 0
    self.actor = 0 
    self.answer = nil    
    self.answers = {}     
end




--------------------------------------------------------------------------------
-- @type Actor
-- アクターを表すエンティティです.
-- アクターとしての能力があります.
--------------------------------------------------------------------------------
Actor = class(Entity)
M.Actor = Actor

--- ダメージを受けた時のイベントです.
Actor.EVENT_DAMEGE = "damege"

--- 死亡した時のイベントです.
Actor.EVENT_DEAD = "dead"

--- 回復した時のイベントです.
Actor.EVENT_RECOVERY = "recovery"

--- 何らかのステータスを更新したときのイベントです.
Actor.EVENT_UPDATE = "update"

---
-- コンストラクタ
function Actor:init()
    Actor.__super.init(self)
    self.id = 0
    self.name = nil
    self.texture = nil
    self.level = 0    
    self.exp = 0      
    self.str = 0
    self.vit = 0
    self.int = 0    
    self.spd = 0
    self.equipItems = {}
    self.equipSkills = {}
    self.talks = {}
    self.statusStates = {}
end

---
-- データを読み込みます.
function Actor:loadData(data)
    self.id = data.id
    self.name = data.name
    self.texture = data.texture
    self.level = data.level    
    self.exp = data.exp        
    self.str = data.str
    self.vit = data.vit
    self.int = data.int    
    self.spd = data.spd

    for i, itemId in ipairs(data.equipItems) do
        local item = assert(repositry:getItemById(itemId), "Not Found Item!", itemId)
        self.equipItems[i] = item
    end
    for i, skillId in ipairs(data.equipSkills) do
        local skill = assert(repositry:getSkillById(skillId), "Not Found Skill", skillId)
        self.equipSkills[i] = skill
    end
    
    if data.talks then
      for i, talk in ipairs(data.talks) do                      
          table.insertElement(self.talks, talk)
      end
    end
end

function Actor:saveData()
    local data = table.copy(self)
    data.__index = nil
    data.__class = nil
    
    data.equipItems = {}
    data.equipSkills = {}
    data.talks = {}
    data.statusStates = {}
    return data
end

---
-- 
function Actor:getTalkById(id)    
    for i, talk in ipairs(self.talks) do
        if talk.id == id then
            return talk
        end
    end    
end


---
-- 武器を装備します.
function Actor:equipWeaponItem(item)
    self.equipItems[1] = item
end

---
-- 防具を装備します.
function Actor:equipArmorItem(item)
    self.equipItems[2] = item
end

---
-- 装備しているスキルリストを返します.
function Actor:getSkills()
    return self.equipSkills
end

---
-- スキルを追加します.
function Actor:addSkill(skill)
    table.insertElement(self.equipSkills, skill)
end

---
-- スキルを削除します.
function Actor:removeSkill(skill)
    table.removeElement(self.equipSkills, skill)
end

---
-- アイテムを使用します.
function Actor:useItem(item)

end

---
-- ターゲットを攻撃します.
-- TODO:スキルはどうやって攻撃するのか
-- @param ターゲット
function Actor:doAttack(target)
    local atkPoint = self:getAtkPoint()
    local defPoint = target:getDefPoint()

    local point = math.max(atkPoint - defPoint / 2, 1)
    target.hp = math.max(target.hp - point, 0)

    -- dispatch event
    target:dispatchEvent(Actor.EVENT_DAMEGE, {damegeHP = point})
    if target.hp <= 0 then
        target:dispatchEvent(Actor.EVENT_DEAD)
    end
    target:dispatchEvent(Actor.EVENT_UPDATE)

    --logger.debug("Attack! NAME:%s, HP:%s", target.name, target.hp)
end

---
-- 攻撃力を返します.
-- @return 攻撃力
function Actor:getAtkPoint()
    local total = self.str
    for i, item in ipairs(self.equipItems) do
        total = total + item.atk
    end
    return total
end

---
-- 防御力を返します.
-- @return 防御力
function Actor:getDefPoint()
    local total = self.vit
    for i, item in ipairs(self.equipItems) do
        total = total + item.def
    end
    return total
end

--------------------------------------------------------------------------------
-- @type Player
-- ユーザが操作するプレイヤーを表すエンティティです.
-- アクターを継承します.
--------------------------------------------------------------------------------
Player = class(Actor)
M.Player = Player

function Player:init()
    Player.__super.init(self)
    self.id = 0
    self.gold = 0
    self.actor = nil    
end

function Player:loadData(data)
    self.id = data.id
    self.gold = data.gold
    self.actor = repositry:getActorById(data.actor_id)
end

function Player:saveData()    
    local player = {}
    player.id = self.id
    player.gold = self.gold
    player.actor_id = self.actor.id
    return player
end

--------------------------------------------------------------------------------
-- @type Enemy
-- マップ上に配置するエネミーを表すエンティティです.
-- アクターを継承します.
--------------------------------------------------------------------------------
Enemy = class(Actor)
M.Enemy = Enemy

---
-- コンストラクタです.
function Enemy:init()
    Enemy.__super.init(self)
end

M.initialize()

return M