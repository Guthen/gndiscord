local RichEmbed = {}

function RichEmbed:new( tbl )
    return setmetatable( tbl or {}, { __index = RichEmbed } )
end

return RichEmbed