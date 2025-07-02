-- PlayerData.lua
-- Data storage for raid members

PlayerData = PlayerData or {}

local function updateAttendance(data)
    data.attendance = math.floor((data.attended / math.max(data.attended + data.absent, 1)) * 100)
end

function AddOrUpdatePlayer(name, class, isRaider)
    local p = PlayerData[name]
    if not p then
        p = {
            name = name,
            class = class,
            isRaider = isRaider or false,
            SP = 0,
            DP = 0,
            tokenItems = {},
            itemHistory = {},
            attended = 0,
            absent = 0,
            attendance = 0,
        }
        PlayerData[name] = p
    else
        p.class = class or p.class
        if isRaider ~= nil then p.isRaider = isRaider end
    end
    updateAttendance(p)
    return p
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
    for name, data in pairs(PlayerData) do
        if IsPlayerInRaid(name) then
            data.SP = (data.SP or 0) + 5
            data.attended = (data.attended or 0) + 1
        else
            data.absent = (data.absent or 0) + 1
        end
        updateAttendance(data)
    end
end

function BroadcastPlayerData()
    if UnitIsGroupLeader("player") or IsMasterLooter() then
        if AceSerializer then
            local serialized = AceSerializer:Serialize(PlayerData)
            SendAddonMessage("PlayerDataUpdate", serialized, "RAID")
        end
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
