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

-- classes
local FaceImage
local ActorImage
local BattlerImage
local MonsterImage
local IconImage
local BitmapLabel

--------------------------------------------------------------------------------
-- @type FaceImage
-- 
--------------------------------------------------------------------------------
FaceImage = class(SheetImage)
M.FaceImage = FaceImage

function FaceImage:init(faceNo)
    FaceImage.__super.init(self, self:getFaceTexturePath(faceNo), 4, 2)
    self:setIndex(1)
end

function FaceImage:setFace(faceNo)
    self._faceNo = faceNo
    self:setTexture(self:getFaceTexturePath(faceNo))
end

function FaceImage:getFaceTexturePath(faceNo)  
    return "faces/face" .. faceNo .. ".png"
end

--------------------------------------------------------------------------------
-- @type ActorImage
-- 
--------------------------------------------------------------------------------
ActorImage = class(MovieClip)
M.ActorImage = ActorImage

function ActorImage:init(texture)
    ActorImage.__super.init(self, texture, 3, 4)
    self:initAnims()
end

function ActorImage:initAnims()
    self:setAnimDatas {
        {name = "down", frames = {2, 1, 2, 3, 2}, sec = 0.1},
        {name = "left", frames = {5, 4, 5, 6, 5}, sec = 0.1},
        {name = "right", frames = {8, 7, 8, 9, 8}, sec = 0.1},
        {name = "up", frames = {11, 10, 11, 12, 11}, sec = 0.1},
    }
end

--------------------------------------------------------------------------------
-- @type IconImage
-- 
--------------------------------------------------------------------------------
IconImage = class(SheetImage)
M.IconImage = IconImage

IconImage.TEXTURE = "icons.png"

function IconImage:init()
    ActorImage.__super.init(self, IconImage.TEXTURE)
end


return M