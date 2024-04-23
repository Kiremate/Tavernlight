--[[ Q1 Fix or improve the implementation of the below methods.--]]
-- Global values
PLAYER_KEY = 1000 -- Storage key for player
EMPTY_STORAGE_VALUE = -1 -- Empty storage value
ON_LOGOUT_STORAGE_EVENT = 1 -- Event id for on logout storage event
EVENT_DELAY_TIME = 1000 -- Delay time in milliseconds

local function releaseStorage(player)
    -- Early returns
    if player == nil then
        return false, "Player is nil"
    end
    local status, result = pcall(player.setStorageValue, player, PLAYER_KEY, EMPTY_STORAGE_VALUE) -- pcall to prevent Player Key not found
    return status, result
end

function OnLogout(player) -- Changed to OnLogout to specify it is not a local function
    -- Early returns
    if not player then
     return false, "Player is nil"

    end

    local status, playerStorageValue =  pcall(player.getStorageValue, player, PLAYER_KEY)

    if not status then -- Player Key not found
        return status, playerStorageValue -- We return the error
    end

    if playerStorageValue == ON_LOGOUT_STORAGE_EVENT then
        local status, result = pcall(addEvent, releaseStorage, EVENT_DELAY_TIME, player)
        return status, result
    end

    return false, "Player storage value is not 1"
end
--[[ Q2 Fix or improve the implementation of the below methods.--]]     -- this method is supposed to print names of all guilds that have less than memberCount max members
-- We asume that the database is already connected and the db variable is available globally
GUILD_QUERY_LESS_MEMBERS_THAN  = "SELECT name FROM guilds WHERE max_members < %d;"
NAME_IDENTIFIER = "name" -- Perhaps in a future there is a long name/short name identifier
function PrintSmallGuildNames(memberCount) -- Changed the name to PrintSmallGuildNames indicating is a global function / perhaps in the codebase the nomenclature is pure camelCase, adapt it later
    -- Check if memberCount is nil or not a valid number
    if not memberCount or type(memberCount) ~= "number" then
        return false, "Member Count not valid"
    end

    local guildQueryFormatted  = string.format(GUILD_QUERY_LESS_MEMBERS_THAN, memberCount)
    local status, guilds = pcall(db.storeQuery, guildQueryFormatted) -- Added pcall to prevent query errors
    if not status or not guilds then -- There are no guilds with less than memberCount members
        return false, "Query failed"
    end
    repeat
        local guildName = guilds.getString(NAME_IDENTIFIER) -- I guess the query returned a structure since there was a getString method in the original code
        if guildName then
            print(guildName)
        end
    until not guilds.next() -- Perhaps like a linked list otherwise change it to a for loop
        guilds.free() -- Assuming the result has a free method so it gets garbage collected
        -- if there is no free method we can call the garbage collector manually (it's expensive so we should avoid it if possible)
end
--[[ Q3 Fix or improve the implementation of the below methods.--]]
function RemovePlayerMemberFromParty(playerId, membername) --  TODO Complexity is quite high improve it later on...
    local player = Player(playerId) -- Made it local to faster access and scope protection
    if not player then
        return false, "Player not found"
    end
    local party = player:getParty() -- Get party reference
    if not party then
        return false, "Player does not have a party or is not in a party"
    end
    local members = party:getMembers()
    local removingMember = Player(membername) -- getting the to be removed player reference
    for key,value in pairs(members) do
        if value == removingMember then -- if the member value matches
        local status, error = pcall(party.removeMember, party, removingMember) -- We can add a pcall here since removeMember could fail
        if not status then
            return status, error
        end
        return true, "Member removed" -- we can also add the member name to the return to make it more verbose for debugging
        end
    end
    return false, "Member not found"
end
