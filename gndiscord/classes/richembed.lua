local RichEmbed = {}
local limits = 
{
    AUTHOR_NAME = 256,
    FIELDS = 25,
    FIELD_NAME = 256,
    FIELD_VALUE = 1024,
    FOOTER_TEXT = 2048,
}

function RichEmbed:new( tbl )
    local embed = tbl or {}
        embed.fields = embed.fields or {}
        embed.footer = embed.footer or {}
        embed.image = embed.image or {}
        embed.thumbnail = embed.thumbnail or {}

    return setmetatable( embed, { __index = RichEmbed } )
end

function RichEmbed:addBlankField( inline )
    self:addField( "\u200B", \u200B", inline )
    return self
end

function RichEmbed:addField( name, value, inline )
    if #self.fields >= limits.FIELDS - 1 then
        error( ( "RichEmbed can not have more than %d fields" ):format( limits.FIELDS ), 2 )
        return self
    end

    self.fields[#self.fields + 1] = { name = name, value = value, inline = inline or false }
    return self
end

function RichEmbed:setAuthor( name, icon, url )
    if #name > limits.AUTHOR_NAME then
        error( ( "RichEmbed can not have more than %d characters in author name" ):format( limits.AUTHOR_NAME, 2 )
        return self
    end

    self.author = { name = name, url = url, icon_url = icon }
    return self
end

return RichEmbed