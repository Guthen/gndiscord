local enum = require( "../enum" )

local Guild = {}

function Guild:new( tbl )
    local guild = tbl
        guild.iconURL = enum.CDN_LINK .. enum.GUILD_ICON_PATH:format( guild.id, guild.icon )

    return setmetatable( guild, { __index = Guild } )
end

return Guild