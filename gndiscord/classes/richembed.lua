local RichEmbed = {}

function RichEmbed:new( tbl )
    local embed = tbl or {}
        embed.fields = embed.fields or {}
        embed.author = embed.author or {}
        embed.footer = embed.footer or {}
        embed.image = embed.image or {}
        embed.thumbnail = embed.thumbnail or {}

    return setmetatable( embed, { __index = RichEmbed } )
end

return RichEmbed