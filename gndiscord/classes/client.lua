local emitter = require( "core" ).Emitter

local API = require( "../api" )
local Gateway = require( "../gateway" )
local User = require( "./user" )
local Guild = require( "./guild" )

local Collection = require( "../utils/functions" ).Collection

local Client = emitter:new()

function Client:new( options )
    local client = {}
        client.version = options.version or "7"
        client.options = options
        client.type = options.type or "Bot"
        client.token = ""

        client.guilds = options.guilds or {}
        client.channels = options.channels or {}
        client.users = options.users or {}

        client._debug = true
        
    return setmetatable( client, { __index = Client } )
end

function Client:login( token )
    self.token = token

    Gateway:connect( self )
end

function Client:debug( txt, ... )
    if self._debug then
        print( ( "%s - %s" ):format( self.user and self.user.tag or "?", ( txt ):format( ... ) ) )
    end
end

local events = 
{
    READY = function( client, data )
        client.user = User:new( data.user )
        client.session_id = data.session_id
        client:emit( "ready" )

        Gateway:heartbeat( client )
    end,
    GUILD_CREATE = function( client, data )
        local guild = Guild:new( data )

        client:debug( "Creating %q guild", guild.name )

        --  > Adding the users/channels/emojis.. to the client
        client.users = client.users or {}
        for i, v in ipairs( guild.members ) do
            client.users[v.user.id] = User:new( v.user )
        end
        client.channels = client.channels or {}
        for i, v in ipairs( guild.channels ) do
            client.channels[v.id] = v
        end
        client.emojis = client.emojis or {}
        for i, v in ipairs( guild.emojis ) do
            client.emojis[v.id] = v
        end

        --  > Make the users/channels/emojis... as collections instead of arrays
        guild.members = Collection( guild.members, "user" )
        guild.channels = Collection( guild.channels )
        guild.emojis = Collection( guild.emojis ) 

        client.guilds[data.id] = guild
    end,
    PRESENCE_UPDATE = function( client, data )
        local guild = client.guilds[data.guild_id]
        if not guild then return client:debug( "Guild with ID %q isn't registered, presence update canceled", data.guild_id ) end
        
        local user = guild.members[data.user.id]
            user = user and user.user

        if user then
            user.presence = 
            {
                clientStatus = data.client_status,
                status = data.status,
                game = data.game,
            }
            client:debug( "Update presence of %q", user.tag )
        else
            client:debug( "Can't update presence of %q because it can't be found in %q", user.tag, guild.name )
        end
    end,
}

function Client:handleGatewayEvent( payload )
    local event = payload.t

    if events[event] then
        events[event]( self, payload.d )
    else
        self:debug( "Client can't handle %q event.", event )
    end
end

return Client