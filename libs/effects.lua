----------------------------------------------------------------------------------------------------
-- エフェクトを定義するモジュールです.
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
local DamegeEffect
local BalloonEffect

--------------------------------------------------------------------------------
-- @type Effect
-- エフェクトの抽象クラスです.
-- 共通的な動作を定義します.
--------------------------------------------------------------------------------
Effect = class(Group)
M.Effect = Effect

--- エフェクト完了時のイベントです.
Effect.EVENT_COMPLETE = "complete"

function Effect:init()
    Effect.__super.init(self)
end

---
-- エフェクトを開始します.
-- @param エフェクト対象のターゲット
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

---
-- 実際にエフェクトを行う関数です.
-- コールチン経由で起動されます.
-- デフォルトでは空実装なので、この関数を継承してください.
function Effect:_doEffect()
end

--------------------------------------------------------------------------------
-- @type BalloonEffect
-- ダメージが発生した時のエフェクトです.
-- ダメージポイントを表示します.
--------------------------------------------------------------------------------
BalloonEffect = class(Effect)
M.BalloonEffect = BalloonEffect

---
-- コンストラクタ
-- @param point ダメージポイント
function BalloonEffect:init(effectEntity)
    BalloonEffect.__super.init(self)
    self._effectImage = MovieClip(effectEntity.texture, effectEntity.tileSize[1], effectEntity.tileSize[2])
    self._effectImage:setAnimData("effect", effectEntity.effectData)
    self:addChild(self._effectImage)
end

---
-- ダメージエフェクトを表示します.
function BalloonEffect:_doEffect()
    local parentW, parentH = self.parent:getSize()
    local effectW, effectH = self._effectImage:getSize()
    self._effectImage:setPos(-16,-92)   
    self._effectImage:setPriority(self.parent:getPriority())
    self._effectImage:playAnim("effect")
    while self._effectImage:isBusy() do
        coroutine.yield()
    end
end



return M