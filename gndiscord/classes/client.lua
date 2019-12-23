local API = require( "../api" )
local Gateway = require( "../gateway" )
local User = require( "./user" )
local Guild = require( "./guild" )

local Client = {}

function Client:new( options )
    local client = {}
        client.version = options.version or "7"
        client.options = options
        client.type = options.type or "Bot"
        client.token = ""

        client.guilds = {}
        client.channels = {}
        client.users = {}

        client.events = {}
        
    return setmetatable( client, { __index = Client } )
end

function Client:login( token )
    self.token = token

    local i = 0
    local function callReady()
        i = i + 1
        if i >= 2 then 
            self:call( "ready" )
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

function Client:on( event, callback )
    if not self.events[event] then self.events[event] = {} end

    self.events[event][#self.events[event] + 1] = callback
end

function Client:call( event, ... )
    if not self.events[event] then return end

    for i, v in ipairs( self.events[event] ) do
        v( ... )
    end
end

return Client