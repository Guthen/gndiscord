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
--  > Good HTTP response codes from https://discordapp.com/developers/docs/topics/opcodes-and-status-codes#http-http-response-codes
local success_response = 
{
    ["200"] = true,
    ["201"] = true,
    ["204"] = true,
    ["304"] = true,
}

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
            local data = json.parse( raw_data )
            if data.message then
                local code = data.message:sub( 1, 3 )
                print( code, success_response[code] )
                if not success_response[code] then
                    print( "Getting a message while request to the API : " .. data.message )
                    return
                end
            end

            callback( data, raw_data )
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