local conf = require( "./conf" )

local Discord = require( "./gndiscord" )
local client = Discord.Client()

client:on( "ready", function() -- ça ne met pas le bot en on parce qu'il faut passer par la gateway en plus de l'api (est jsp komen fer :()
    print( client.user.tag .. " is ready !" )
end )

client:login( conf.token )
