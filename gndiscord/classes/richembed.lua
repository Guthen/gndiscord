local RichEmbed = {}

local function set( tbl, key, value )
    tbl[key] = tbl[key] or value
end

function RichEmbed:new( data )
    local embed = data or {}
        set( embed, "title", "Title" )
        set( embed, "description", "Description" )

end

return RichEmbed