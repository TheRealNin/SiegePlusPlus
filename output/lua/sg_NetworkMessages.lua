//
//	ns2siege+ Custom Game Mode
//	ZycaR (c) 2016
//

kSiegeMessageTypes = enum({
    'FrontDoorOpened',
    'SiegeDoorOpened',
    'SuddenDeathActivated'
})

// Network Message transfer stuff
local kSiegeMessageMessage = {
    type = "enum kSiegeMessageTypes"
}

Shared.RegisterNetworkMessage("SiegeMessage", kSiegeMessageMessage)

if Server then
    function SendSiegeMessage(team, messageType)
        if GetGamerules():GetGameStarted() then
            local function SendToPlayer(player)
                Server.SendNetworkMessage(player, "SiegeMessage", { type = messageType }, true)
            end
            team:ForEachPlayer(SendToPlayer)
        end        
    end
end

if Client then

    local kSiegeMessages = {
        [kSiegeMessageTypes.FrontDoorOpened] = "Front Door Now Open",
        [kSiegeMessageTypes.SiegeDoorOpened] = "Siege Door Now Open",
        [kSiegeMessageTypes.SuddenDeathActivated] = "Sudden Death Mode Activated"
    }

    function OnCommandSiegeMessage(message)
        local text = kSiegeMessages[message.type]
        local player = Client.GetLocalPlayer()
        
        if text and player and HasMixin(player, "TeamMessage") then
            text = Locale.ResolveString(text)
            assert(type(text) == "string")
            
            player:SetTeamMessage(string.UTF8Upper(text))
        end        
    end

    Client.HookNetworkMessage("SiegeMessage", OnCommandSiegeMessage)
end