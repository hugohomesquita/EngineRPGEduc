local M = {}

-- import
local flower = require "hanappe/flower"
local class = flower.class
local table = flower.table

local QuizData
local Save

QuizData = class()
M.QuizData = QuizData

function QuizData:init()
    self._entities = {}
    self._saves = dofile('minigames/data/players_info.lua')
    for i, data in ipairs(self._saves) do
        local entity = Save()
        entity:loadData(data)        
        table.insertElement(self._entities, entity)
    end
end

function QuizData:getDataByPlayerId(id)
    assert(id)
    for i, entity in ipairs(self._entities) do
        if entity.player_id == id then            
            return entity
        end
    end
end

Save = class()
M.Save = Save

function Save:init()
end

function Save:loadData(data)    
    self.player_id = data.player_id
    self.pular = data.pular
    self.verResposta = data.verResposta
end

return M