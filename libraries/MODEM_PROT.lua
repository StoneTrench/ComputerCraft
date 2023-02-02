local function M_PROTOCOL_FUNC()
    -- #region Old
    -- local modem = peripheral.find("modem");

    -- if modem == nil then
    --     error("No modem found!")
    --     return;
    -- end
    -- require("LSON")

    -- local function shouldClose()
    --     return false;
    -- end

    -- local function createServer(serverChannel, serverID)
    --     local key = math.random(2147483647)
    --     modem.open(serverChannel);

    --     print("Server open at " + serverChannel + ":" + serverID)

    --     local clients = {};
    --     local replyChannelCounter = 0;

    --     while not shouldClose() do
    --         local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message");
    --         if channel == serverChannel then
    --             local recievedPacket = LSON.Deserialize(message);

    --             -- TODO make more advanced header

    --             if not (recievedPacket == nil) then
    --                 if recievedPacket.header == "handshake" then
    --                     if recievedPacket.data.serverID == serverID then

    --                         modem.transmit(replyChannel, LSON.Serialize({
    --                             header = "handshake",
    --                             data = {
    --                                 replyChannel = replyChannelCounter
    --                             }
    --                         }))

    --                         replyChannelCounter = replyChannelCounter + 1;

    --                         table.insert(clients, replyChannel);
    --                     end
    --                 else

    --                 end
    --             end
    --         end
    --     end
    -- end

    -- local function createClient(serverChannel, serverID)

    -- end

    -- return {
    --     createServer = createServer,
    --     createClient = createClient
    -- }
    -- #endregion

    local function Transmit()
        
    end

    local function Handshake()
    end
end

M_PROTOCOL = M_PROTOCOL_FUNC();
