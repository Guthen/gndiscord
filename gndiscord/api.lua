local https = require( "https" )
local json = require( "json" )

local enum = require( "./enum" )

local function parse_url( host )
    local hostname, path = host:match( "://(.+%.%w+)(/.+)" )

    return 
    {
        hostname = hostname,
        path = path,
    }
end

local API = {}

function API:setClient( client )
    client.auth = ( "%s %s" ):format( client.type, client.token )

    self.auth = client.auth
    self.api_url = enum.API_LINK:format( client.version )
end

function API:get( host, callback )
    local options = parse_url( host )
    options.headers = 
    {
        ["Authorization"] = API.auth
    }

    local raw_data = ""
    return https.get( options, function( tbl )
        tbl:on( "data", function( data )
            raw_data = raw_data .. data
        end )
        tbl:on( "end", function()
            callback( json.parse( raw_data ), raw_data )
        end )
    end )
end

function API:getGateway( callback )
    self:get( self.api_url .. enum.GATEWAY_PATH, callback )
end

function API:getGatewayBot( client, callback )
    self:setClient( client )

    self:get( self.api_url .. enum.GATEWAY_BOT_PATH, callback )
end

function API:getClientUser( client, callback )
    self:setClient( client )

    self:get( self.api_url .. enum.CLIENT_USER_PATH, callback )
end

function API:getClientGuilds( client, callback )
    self:setClient( client )

    self:get( self.api_url .. enum.CLIENT_GUILDS_PATH, callback )
end

return API