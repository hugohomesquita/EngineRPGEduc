----------------------------------------------------------------------------------------------------
-- Módulo de Eventos Utilizados nos Mapas
--
----------------------------------------------------------------------------------------------------

-- module
local M = {}

-- import
local flower = require "hanappe/flower"
local class = flower.class

-- class
local MapEvent
--------------------------------------------------------------------------------
-- @type MapEvent
-- 
--------------------------------------------------------------------------------
MapEvent = class()
M.MapEvent = MapEvent

MapEvent.EVENT_COLLISION_BEGIN = "collisionBegin"
MapEvent.EVENT_COLLISION_END = "collisionEnd"
MapEvent.EVENT_COLLISION_PRE_SOLVE = "collisionPreSolve"
MapEvent.EVENT_COLLISION_POST_SOLVE = "collisionPostSolve"

MapEvent.TALK = "talk"
MapEvent.TELEPORT = "teleport"
MapEvent.MINIGAME = "minigame"



return M