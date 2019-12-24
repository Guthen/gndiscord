local conf = require( "./conf" )

local Discord = require( "./gndiscord" )
local client = Discord.Client()

client:on( "ready", function()
    print( client.user.tag .. " is ready !" )
end )

client:login( conf.token )
