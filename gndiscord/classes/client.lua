local emitter = require( "core" ).Emitter

local API = require( "../api" )
local Gateway = require( "../gateway" )
local User = require( "./user" )
local Guild = require( "./guild" )

local Client = emitter:new()

function Client:new( options )
    local client = {}
        client.version = options.version or "7"
        client.options = options
        client.type = options.type or "Bot"
        client.token = ""

        client.guilds = {}
        client.channels = {}
        client.users = {}

        
    return setmetatable( client, { __index = Client } )
end

function Client:login( token )
    self.token = token

    local i = 0
    local function callReady()
        i = i + 1
        if i >= 2 then 
            self:emit( "ready" )
        end
    end

    API:getClientUser( self, function( tbl )
        self.user = User:new( tbl )

        callReady()
    end )
    API:getClientGuilds( self, function( tbl )
        self.guilds = {}

        for i, v in ipairs( tbl ) do
            self.guilds[v.id] = Guild:new( v )
        end

        callReady()
    end )

    Gateway:connect( self )
end

return Client