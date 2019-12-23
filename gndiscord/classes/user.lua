local enum = require( "../enum" )

local User = {}

function User:new( tbl )
    local user = tbl
        user.avatarURL = enum.CDN_LINK .. ( enum.AVATAR_USER_PATH ):format( user.id, user.avatar )
        user.tag = ( "%s#%s" ):format( user.username, user.discriminator )

    return setmetatable( user, { __index = User } )
end

return User