----------------------------------------------------------------------------------------------------
-- 
--
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "hanappe/flower"
local class = flower.class
local table = flower.table
local Group = flower.Group
local SheetImage = flower.SheetImage
local MovieClip = flower.MovieClip
local Label = flower.Label

-- classes
local Effect
local BalloonEffect

--------------------------------------------------------------------------------
-- @type Effect
--------------------------------------------------------------------------------
Effect = class(Group)
M.Effect = Effect

--- 
Effect.EVENT_COMPLETE = "complete"

function Effect:init()
    Effect.__super.init(self)
end


function Effect:play(target)
    self:setParent(target)
    self:setLayer(target.layer)    
    
    flower.callOnce(
    function()
        self:_doEffect()
        self:setParent(nil)
        self:setLayer(nil)
        self:dispatchEvent(Effect.EVENT_COMPLETE)        
    end)
end


function Effect:_doEffect()
end

--------------------------------------------------------------------------------
-- @type BalloonEffect
-- 
--------------------------------------------------------------------------------
BalloonEffect = class(Effect)
M.BalloonEffect = BalloonEffect

---
-- 
-- @param point
function BalloonEffect:init(effectEntity)
    BalloonEffect.__super.init(self)
    self._effectImage = MovieClip(effectEntity.texture, effectEntity.tileSize[1], effectEntity.tileSize[2])
    self._effectImage:setAnimData("effect", effectEntity.effectData)
    self:addChild(self._effectImage)
end

---
-- 
function BalloonEffect:_doEffect()
    local parentW, parentH = self.parent:getSize()
    local effectW, effectH = self._effectImage:getSize()
    --self._effectImage:setPos(-16,-92)   
    self._effectImage:setPos(0,-33)   
    self._effectImage:setPriority(self.parent:getPriority())
    self._effectImage:playAnim("effect")
    while self._effectImage:isBusy() do
        coroutine.yield()
    end
end



return M