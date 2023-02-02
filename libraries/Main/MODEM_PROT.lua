local function M_PROTOCOL_FUNC()

    local function Ping(modem, channel, data, timeout)
        if not modem.isOpen(channel) then
            modem.open(channel)
        end

        modem.transmit(channel, channel, data);

        -- event, side, channel, replyChannel, message, distance
        local modem_message = nil;
        repeat
            modem_message = UTILITY.PullEventTimeout("modem_message", timeout)
        until (modem_message == nil) or (modem_message[3] == channel)

        if modem_message == nil then
            return nil;
        end

        modem.close(channel)

        return modem_message[5], modem_message[6];
    end

    return {
        getDefaultSearchChannel = function()
            return 65535;
        end,
        Ping = Ping,
    }
end

M_PROTOCOL = M_PROTOCOL_FUNC();
