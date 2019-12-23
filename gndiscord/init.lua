local enum = require( "./enum" )
local Client = require( "./classes/client" )

local Discord = {}

function Discord.Client( options )
    local options = options or {}
        
    return Client:new( options )
end

return Discord