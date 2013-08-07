----------------------------------------------------------------------------------------------------
-- Módulo que define as entidades da plataforma.
--
--
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "hanappe/flower"
local class = flower.class
local table = flower.table
local EventDispatcher = flower.EventDispatcher

-- classes
local Entity
local EntityPool
local EntityRepositry
local EntityWorld
local EntitySystem

local Actor
local Player
local Skill
local Effect
local Talk

-- variables
local entityPool
local repositry
local world

---
-- 
function M.initialize()
    repositry = EntityRepositry()
    entityPool = EntityPool()
    entityPool:initEntities()

    M.repositry = repositry    
    --VERIFICAR
    M.entityPool = entityPool
end

--------------------------------------------------------------------------------
-- @type Entity
-- Classe que define uma entidade.
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
-- 
--------------------------------------------------------------------------------
EntityPool = class()
M.EntityPool = EntityPool

---
-- 
function EntityPool:init()
end

---
-- Inicializa as Entidades
function EntityPool:initEntities()
    self.skills = self:createEntities(Skill, dofile("data/skill_data.lua"))    
    self.effects = self:createEntities(Effect, dofile("data/effect_data.lua"))    
    self.actors = self:createEntities(Actor, dofile("data/actor_data.lua"))        
    self.players = self:createEntities(Player, dofile("data/player_data.lua"))
    self.talks = self:createEntities(Talk, dofile("data/talk_data.lua"))    
end

---
-- Carrega as entidades salvas para a memória
function EntityPool:loadEntities(saveId)
    self.actors = self:createEntities(Actor, dofile("save" .. saveId .. "/actor_data.lua"))    
end

---
-- Salva as entidades da memória.
function EntityPool:saveEntities(saveId)
    local actors = {}
    for i, actor in pairs(entityPool.actors) do        
        table.insertElement(actors, actor:saveData())                
    end
    self:saveEntity(actors, "saves/profile_".. tostring(saveId) .."_actor_data.lua")               
end

---
-- Criação de classes de entidade que você especificar.
-- @param clazz Classe da entidade
-- @param entityDataList Lista de dados da entidade
function EntityPool:createEntities(clazz, entityDataList)
    local entities = {}
    for i, data in ipairs(entityDataList) do
        local entity = clazz()
        entity:loadData(data)
        table.insertElement(entities, entity)
    end
    return entities
end

function EntityPool:saveEntity(entityList, path)    
    local file = io.open(path, 'wb')
    file:write("return {\n")
    for i, entity in pairs(entityList) do
        self:save(entity, file)
    end
    file:write("\n}")
    file:close()
end

function EntityPool:save(table, file)
    local type = type
    local tostring = tostring
    
    local function thatkey(k)
      if type(k)=="number" then
        return ""
      end
      return k 
    end
    
    local function key_number(k,v)
      if type(k)=="number" then
        return "\t"
      end
      return "\t[\"" .. k .. "\"] = "
    end 
    
    local function saveTable(name,_table)      
        file:write("\t" .. name .. " = ")
        
        file:write("{")
        for i, v in pairs(_table) do        
          local the_type = type(v) 
          local old_i = i       
          local i = thatkey(i)
          local i_string = key_number(old_i, v)
          
          if the_type == "string" then
              file:write(" " .. i  .. string.format("%q",v))
          elseif the_type == "number" then 
              file:write(" " .. i  .. tostring(v))
          elseif the_type == "table" then
              saveTable(i, v)
          end
          if next(_table, old_i) then file:write(",") else file:write("") end
        end      
        file:write(" }")
    end
        
    file:write("{\n")
    for i, v in pairs(table) do
        local the_type = type(v)
        local old_i = i        
        local i_string = key_number(old_i,v)
        
        if the_type == "string" then
            file:write("\t" .. i .. " = " .. string.format("%q",v))
        elseif the_type == "number" then 
            file:write("\t" .. i .. " = " .. tostring(v))
        elseif the_type == "table" then
            saveTable(i, v)
        end
        if next(table, old_i) then file:write(",\n") else file:write("") end
    end
    file:write("\t\n},\n")
    
end

--------------------------------------------------------------------------------
-- @type EntityRepositry
-- A classe responsável por acessar as entidades.
--------------------------------------------------------------------------------
EntityRepositry = class()
M.EntityRepositry = EntityRepositry

---
-- Construtor.
function EntityRepositry:init()
end

---
-- Retorna a entidade na lista pelo ID.
-- @return Entidade pelo id
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
-- Retorna uma lista de todos os atores.
-- @return Lista de Atores
function EntityRepositry:getActors()
    return entityPool.actors
end

---
-- Retorna um actor pelo ID.
-- @return Ator
function EntityRepositry:getActorById(id)
    return self:getEntityById(entityPool.actors, id)
end

function EntityRepositry:getTalkById(id)
    return self:getEntityById(entityPool.talks, id)
end

---
-- 
-- 
function EntityRepositry:getPlayers()
    return entityPool.players
end

function EntityRepositry:getPlayerById(id)
    return self:getEntityById(entityPool.players, id)
end

function EntityRepositry:savePlayerById(id, saveId)
    local player = self:getEntityById(entityPool.players, id)
    local entities = {}        
    table.insertElement(entities,player:saveData())
    entityPool:saveEntity(entities, "saves/profile_".. tostring(saveId) .."_player_data.lua")
end

---
-- 
-- @return 
function EntityRepositry:getSkills()
    return entityPool.skills
end

---
-- 
-- @return 
function EntityRepositry:getSkillById(id)
    return self:getEntityById(entityPool.skills, id)
end

---
-- 
-- @return 
function EntityRepositry:getEffects()
    return entityPool.effects
end

---
-- 
-- @return 
function EntityRepositry:getEffectById(id)
    return self:getEntityById(entityPool.effects, id)
end


--------------------------------------------------------------------------------
-- @type Skill
-- 
--------------------------------------------------------------------------------
Skill = class(Entity)
M.Skill = Skill

---
-- Construtor
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
-- 
--------------------------------------------------------------------------------
Effect = class(Entity)
M.Effect = Effect

---
-- Construtor
function Effect:init()
    self.id = 0
    self.name = nil
    self.texture = nil
    self.tileSize = nil
    self.effectData = nil
end

--------------------------------------------------------------------------------
-- @type Talk
-- 
--------------------------------------------------------------------------------
Talk = class(Entity)
M.Talk = Talk

---
-- Construtor
function Talk:init()    
    self.id = 0
    self.actor = 0 
    self.type = nil
    self.text = nil    
    self.answers = {}
    self.actions = {}
end

---
-- 
function Talk:getActionByIdAnswer(id)
    for i, action in ipairs(self.actions) do
        if action.answer_id == id then
            return action 
        end
    end
end  
  
--------------------------------------------------------------------------------
-- @type Actor
-- Classe que representa os atores
-- Herda Entity
--------------------------------------------------------------------------------
Actor = class(Entity)
M.Actor = Actor

---
-- Construtor
function Actor:init()
    Actor.__super.init(self)
    self.id = 0
    self.name = nil
    self.texture = nil    
end

---
-- 
function Actor:loadData(data)
    self.id = data.id
    self.name = data.name
    self.texture = data.texture            
end

---
-- 
function Actor:saveData()    
    local data = {}
    data.id = self.id
    data.name = self.name
    data.texture = self.texture         
    return data
end


--------------------------------------------------------------------------------
-- @type Player
-- Classe que representa os jogadores.
-- Herda Actor.
--------------------------------------------------------------------------------
Player = class(Entity)
M.Player = Player

---
-- Construtor
function Player:init()
    Player.__super.init(self)
    self.id = 0
    self.gold = 0
    self.name = nil
    self.current_map = nil
    self.actor = nil    
    self.level = 0    
    self.exp = 0      
    self.str = 0
    self.vit = 0
    self.int = 0    
    self.spd = 0    
    self.equipSkills = {}        
end

---
-- 
function Player:loadData(data)
    self.id = data.id
    self.gold = data.gold
    self.name = data.name
    self.current_map = data.current_map
    self.actor = repositry:getActorById(data.actor_id)
    self.level = data.level    
    self.exp = data.exp        
    self.str = data.str
    self.vit = data.vit
    self.int = data.int    
    self.spd = data.spd   
    
    for i, skillId in ipairs(data.equipSkills) do
        local skill = assert(repositry:getSkillById(skillId), "Not Found Skill", skillId)
        self.equipSkills[i] = skill
    end
    
end

---
-- 
function Player:saveData()
    local data = {}
    data.id = self.id
    data.gold = self.gold
    data.name = self.name
    data.actor_id = self.actor.id                
    data.level = self.level    
    data.exp = self.exp        
    data.str = self.str
    data.vit = self.vit
    data.int = self.int    
    data.spd = self.spd       
    data.equipSkills = {}
    
    for i, skill in ipairs(self.equipSkills) do
      data.equipSkills[i] = skill.id
    end    
    
    return data
end

---
-- 
function Player:getSkills()
    return self.equipSkills
end

---
-- 
function Player:addSkill(skill)
    table.insertElement(self.equipSkills, skill)
end

---
-- 
function Player:removeSkill(skill)
    table.removeElement(self.equipSkills, skill)
end

M.initialize()

return M