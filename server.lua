local restrictions = {}
local Categories = { 'vehicles', 'peds', 'weapons' }

-- build restrictions
for _, category in ipairs(Categories) do
    local restriction = { ['everyone'] = {} }
    for ace, bl in pairs(Restricted[category]) do
        if not bl then
            for _, v in ipairs(ace) do
                restriction.everyone[v] = true
            end
        else
            if not restriction[ace] then
                restriction[ace] = { [bl] = true }
            else
                for _, v in ipairs(bl) do
                    restriction[ace][v] = true
                end
            end
        end
    end
    -- setup inheritance
    for parent, child in pairs(Inherits) do
        ExecuteCommand('add_ace ' .. Prefix .. '.' .. parent .. '.' .. category .. ' ' .. Prefix .. '.' .. child .. '.' .. category .. ' allow')
    end
    restrictions[category] = restriction
end

-- filter restrictions
RegisterNetEvent('dblacklist:getClientBlacklist')
AddEventHandler('dblacklist:getClientBlacklist', function ()
    local blacklist = {}
    for category, aces in pairs(restrictions) do
        if not blacklist[category] then blacklist[category] = {} end
        for ace, bl in pairs(aces) do
            if not IsPlayerAceAllowed(source, Prefix..'.'..ace..'.'..category) then
                for name, _ in pairs(bl) do
                    blacklist[category][GetHashKey(name)] = true
                end
            end
        end
    end
    TriggerClientEvent('dblacklist:setClientBlacklist', source, blacklist)
end)