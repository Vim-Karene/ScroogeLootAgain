-- PlayerData.lua
-- Data storage for raid members

PlayerData = PlayerData or {}

local addon = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")

function CanEditPlayerData()
    return addon.isMasterLooter
end

function AddOrUpdatePlayer(name, class, raiderrank)
    local p = PlayerData[name]
    if not p then
        p = {
            name = name,
            class = class,
            raiderrank = raiderrank or false,
            SP = 0,
            DP = 0,
            attended = 0,
            absent = 0,
            attendance = 0,
            item1 = "",
            item1received = false,
            item2 = "",
            item2received = false,
            item3 = "",
            item3received = false,
        }
        PlayerData[name] = p
    else
        p.class = class or p.class
        if raiderrank ~= nil then p.raiderrank = raiderrank end
    end
    updateAttendance(p)
    return p
end

function updateAttendance(p)
    local total = math.max(p.attended + p.absent, 1)
    p.attendance = math.floor((p.attended / total) * 100)
end

function IsPlayerInRaid(name)
    local num = GetNumGroupMembers() or 0
    for i = 1, num do
        local n = GetRaidRosterInfo(i)
        if n == name then return true end
    end
    return false
end

function RaidDayReward()
    if not CanEditPlayerData() then return end
    for name, data in pairs(PlayerData) do
        if IsPlayerInRaid(name) then
            data.SP = (data.SP or 0) + 5
            data.attended = (data.attended or 0) + 1
        else
            data.absent = (data.absent or 0) + 1
        end
        updateAttendance(data)
    end
    BroadcastPlayerData()
end

function BroadcastPlayerData()
    if addon.isMasterLooter then
        local serialized = AceSerializer:Serialize(PlayerData)
        SendAddonMessage("PlayerDataUpdate", serialized, "RAID")
    end
end

-- Simple button to trigger raid day reward
if not RaidDayRewardButton then
    RaidDayRewardButton = CreateFrame("Button", "RaidDayRewardButton", UIParent, "UIPanelButtonTemplate")
    RaidDayRewardButton:SetSize(120, 22)
    RaidDayRewardButton:SetText(L and L["Raid Day Reward"] or "Raid Day Reward")
    RaidDayRewardButton:SetPoint("CENTER", UIParent, "CENTER", 0, -200)
    RaidDayRewardButton:SetScript("OnClick", RaidDayReward)
    RaidDayRewardButton:Hide()
end
