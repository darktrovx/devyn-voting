local QBCore = exports['qb-core']:GetCoreObject()

local Voted = {}
local ElectionData = {}

AddEventHandler('onResourceStart', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
    Wait(1000)
    TriggerClientEvent("vote:updateElections", -1, Elections)
    getCurrentElection()
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
    saveVotes()
end)

QBCore.Commands.Add("vote", "[ADMIN COMMAND]: Open Voting Menu", {}, true, function(source, args)
    local src = source
    TriggerClientEvent("vote:openMenu", src, {admin=true})
end, "god")

QBCore.Functions.CreateCallback("elections:getElections", function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    cb(Elections)
end)

QBCore.Functions.CreateCallback("elections:admin", function(source, cb)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    cb(ElectionData)
end)

RegisterServerEvent("vote:submit", function(votes)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local cid = player.PlayerData.citizenid

    if not checkVotes(cid) then
        table.insert(Voted, cid)
        for position, nominee in pairs(votes) do
            if ElectionData[position][nominee] == nil then
                ElectionData[position][nominee] = 1
            else 
                ElectionData[position][nominee] = ElectionData[position][nominee] + 1
            end
        end
    else 
        TriggerClientEvent("QBCore:Notify", src, "You have already voted!", "error")
    end
end)

function checkVotes(cid)
    if Voted ~= nil then 
        for k,v in pairs(Voted) do
            if k == cid or v == cid then 
                return true 
            end
        end 
        return false
    else
        Voted = {}
        return false 
    end
end

function getCurrentElection()
    local elections = promise.new()
    MySQL.Async.fetchAll('SELECT * FROM player_voting WHERE ElectionName = ?', {ElectionName}, function(result)
        if result[1] then 
            elections:resolve(result[1])
        else
            local defaultVotes = {}
            for k,v in pairs(Elections) do 
                defaultVotes[k] = {}
                for k2,v2 in pairs(v) do
                    defaultVotes[k][v2] = 0
                end
            end
            MySQL.Async.insert("INSERT INTO player_voting (ElectionName, ElectionVotes, AlreadyVoted, CreateDate) VALUES (?, ?, ?, ?)", {
                ElectionName, json.encode(defaultVotes), json.encode({}), os.date("%Y%m%d")
            }, function(success)
                if success ~= nil then 
                    MySQL.Async.fetchAll('SELECT * FROM player_voting WHERE ElectionName = ?', {ElectionName}, function(result)
                        elections:resolve(result[1])
                    end)
                else 
                    print("[ELECTIONS]: An error has occured while inserting a new record for : "..ElectionName)
                end
            end)
        end
    end)
    local data = Citizen.Await(elections)
    ElectionData = json.decode(data["ElectionVotes"])
    Voted = json.decode(data["AlreadyVoted"])
end

function saveVotes()
    MySQL.Async.execute('UPDATE player_voting SET ElectionVotes = ?, AlreadyVoted = ?', {
        json.encode(ElectionData),
        json.encode(Voted),
    }, function(affectedRows) end)
end
