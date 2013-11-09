----------------------------------------------------------------------------------------------------
-- @type PlayerController
-- 
----------------------------------------------------------------------------------------------------

local flower = require "hanappe/flower"
local entities = require "libs/entities"
local ActorController = require "hanappe/plataform/ActorController"
local class = flower.class
local repositry = entities.repositry


local PlayerController = class(ActorController)

function PlayerController:initController()
    PlayerController.__super.initController(self)    
    self.player = repositry:getPlayerById(1)
    self.entity = self.player.actor
end

return PlayerController