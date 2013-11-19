----------------------------------------------------------------------------------------------------
-- @type CameraSystem
----------------------------------------------------------------------------------------------------

local flower = require "hanappe/flower"
local entities = require "libs/entities"
local class = flower.class
local repositry = entities.repositry


local EffectSystem = class()
local BalloonEffect = effects.BalloonEffect
EffectSystem = class()

function EffectSystem:init(tileMap)
    self.tileMap = assert(tileMap)
    
end

function EffectSystem:initEffect()  
    for i, event in ipairs(self.tileMap.mapActorLayer.children) do
        if event.type == 'Actor' then
            local effectId = event:getProperty('effectId')                          
            if effectId ~= null then
              local effect = BalloonEffect(repositry:getEffectById(tonumber(effectId)))                      
              effect:play(event)
            end
        end
    end       
end

return EffectSystem