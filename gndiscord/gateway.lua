local ws = require( "coro-websocket" )
local json = require( "json" )
local timer = require( "timer" )
local los = require( "los" )

local API = require( "./api" )

local Gateway = {}
--  > definitions of all opcodes from https://discordapp.com/developers/docs/topics/opcodes-and-status-codes#gateway-opcodes
local op = 
{
    --  > Gateway
    DISPATCH = 0,
    HEARTBEAT = 1,
    IDENTIFY = 2,
    STATUS_UPDATE = 3,
    VOICE_STATE_UPDATE = 4,
    RESUME = 6,
    RECONNECT = 7,
    REQUEST_GUILD_MEMBERS = 8,
    INVALID_SESSION = 9,
    HELLO = 10,

    --  > WebSocket package
    TEXT = 1,
    BINARY = 2,
    CLOSE = 8,
}

--  # TODO: Accelerate heartbeat time to get informations faster (use timeout and recreate one once done)

--  > get the len of non numerical tables
local function table_count( tbl )
    local len = 0

    table.foreach( tbl, function()
        len = len + 1
    end )

    return len
end

--  > add the params to the url to specify the version and the encoding
local function format_url_params( args )
    local len, i = table_count( args ), 0
    local url = ""

    for k, v in pairs( args ) do
        i = i + 1
        url = ( "%s%s%s=%s" ):format( url, i == len and "&" or "?", k, v )
    end

    return url
end

--  > get the table from the received payloads
local function parse_payload( tbl )
    return json.decode( tbl.payload )
end

function Gateway:send( client, opcode, tbl )
    --  > if gateway is locked don't continue
    if self.locked then 
        print( "Gateway is locked, abort sending data.." )
        return
    end
    --  > don't continue if we are not connected
    if not self._write then 
        print( "Gateway isn't connected" )
        return 
    end

    local message = {
        payload = json.encode( { op = opcode, d = tbl } ),
        opcode = op.TEXT,
    }

    p( "preparing to send", opcode, message.payload )
    coroutine.wrap( function()
        self._write( message )
        p( "sent" )
    end )()

    self:receive( client )
end

function Gateway:receive( client )
    coroutine.wrap( function() 
        local message = self._read()
        p( "received", message )

        if message then
            local payload = parse_payload( message ) or {}
            --  > locking the gateway if discord want us to close connection
            if message.opcode == op.CLOSE then
                self.locked = true
                print( "Gateway has been locked cause of opcode 8 : " .. message.payload )
                self:disconnect( client, true )
            elseif payload.t then
                client:handleGatewayEvent( payload )
            end

            if payload.s then
                client.last_sequence = payload.s
            end
        else
            self:disconnect( client, true )
        end
    end )()
end

function Gateway:connect( client )
    if not client then return end
    --  > set the lock to determine sending data or not
    self.locked = false

    API:getGatewayBot( client, function( tbl )
        client:debug( "Remaining %d sessions on %d, reset in %d minutes", tbl.session_start_limit.remaining, tbl.session_start_limit.total, tbl.session_start_limit.reset_after / 60000 )
        --  > format the options with the result of the API
        self.options = ws.parseUrl( tbl.url )
        self.options.pathname = "/" .. format_url_params( { v = client.version, encoding = "json" } )

        coroutine.wrap( function()
            --  > connect
            _, self._read, self._write = ws.connect( self.options )
            --  > read response
            local payload = parse_payload( self._read() )
            if not ( payload.op == op.HELLO ) then return end 

            self.locked = false

            --  > starting the heartbeat
            self.heartbeat_interval = payload.d.heartbeat_interval
            self.heartbeat_timer = timer.setInterval( self.heartbeat_interval, function()
                self:heartbeat( client )
            end )

            --  > identify with the client
            self:identify( client )
        end )()
    end )
end

function Gateway:disconnect( client, reconnect )
    self._write()
    self._read = nil
    self._write = nil

    timer.clearInterval( self.heartbeat_timer )
    self.heartbeat_timer = nil

    --  > Reconnection
    if reconnect then
        client:debug( "Trying to resuming connection.." )
        self:connect( client )
    end
end

function Gateway:identify( client )
    --  > identifying as wanted in https://discordapp.com/developers/docs/topics/gateway#identifying
    self:send( client, op.IDENTIFY, { 
        token = client.token, 
        properties = 
        { 
            ["$os"] = los.type(),
            ["$browser"] = "gndiscord",
            ["$device"] = "gndiscord",
        },
        --  > resuming
        session_id = client.session_id,
        seq = client.last_sequence,
    } )
end

function Gateway:heartbeat( client )
    --  > heartbeat as wanted in https://discordapp.com/developers/docs/topics/gateway#heartbeating
    self:send( client, op.HEARTBEAT )
end

return Gateway