--MOAI
serializer = ... or MOAIDeserializer.new ()

local function init ( objects )

	--Initializing Tables
	local table

	table = objects [ 0x03510E18 ]
	table [ "nome" ] = "HUGO"
	table [ "xp" ] = 60

end

--Declaring Objects
local objects = {

	--Declaring Tables
	[ 0x03510E18 ] = {},

}

init ( objects )

--Returning Tables
return objects [ 0x03510E18 ]
