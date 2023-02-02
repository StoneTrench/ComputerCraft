local function M_PROTOCOL_FUNC()

    local function Ping(modem, channel, data)
        if not modem.isOpen(channel) then
            modem.open(channel)
        end

        modem.transmit(channel, channel, data);

        -- event, side, channel, replyChannel, message, distance
        local modem_message;
        repeat
            modem_message = { os.pullEvent("modem_message") }
        until modem_message[3] == channel

        modem.close(channel)

        return modem_message[5], modem_message[6];
    end

    return {
        Ping = Ping,
    }
end

M_PROTOCOL = M_PROTOCOL_FUNC();
