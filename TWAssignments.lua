TWA = {}
local _G = _G or getfenv(0)
local me = UnitName('player')
local TWADropDown = CreateFrame('Frame', 'TWADropDown', UIParent, 'UIDropDownMenuTemplate')

TWA.debug = false
TWA.data = {}
TWA.rows = {}
TWA.cells = {}
TWA.loadedTemplate = nil
TWA.currentRow = 0
TWA.currentCell = 0

local function twaprint(a)
    DEFAULT_CHAT_FRAME:AddMessage("|cff69ccf0[TWA]|r " .. tostring(a))
end

local function twadebug(...)
    if not TWA.debug then return end
    for i = 1, arg.n do arg[i] = tostring(arg[i]) end
    DEFAULT_CHAT_FRAME:AddMessage('|cff69ccf0[TWADEBUG:' .. format("%.3f", GetTime()) .. ']|r[' .. table.concat(arg, " ") .. ']')
end

local function strsplit(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    while delim_from do
        table.insert(result, string.sub(str, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    table.insert(result, string.sub(str, from))
    return result
end

local function wipe(t)
    if type(t) ~= "table" then return {} end
    for i = getn(t), 1, -1 do table.remove(t, i) end
    for k in pairs(t) do t[k] = nil end
    return t
end

if not UIDropDownMenu_CreateInfo then
    local info = {}
    UIDropDownMenu_CreateInfo = function()
        return wipe(info)
    end
end

TWA.templates = {
    ['trash1'] = {
        [0] = "Trash #1",
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Square", "-", "-", "-", "-", "-", "-" },
        [4] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [5] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
    },
    ['trash2'] = {
        [0] = "Trash #2",
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Square", "-", "-", "-", "-", "-", "-" },
        [4] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [5] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
    },
    ['trash3'] = {
        [0] = "Trash #3",
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Square", "-", "-", "-", "-", "-", "-" },
        [4] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [5] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
    },
    ['trash4'] = {
        [0] = "Trash #4",
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Square", "-", "-", "-", "-", "-", "-" },
        [4] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [5] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
    },
    ['trash5'] = {
        [0] = "Trash #5",
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Square", "-", "-", "-", "-", "-", "-" },
        [4] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [5] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
    },
    ['gaar'] = {
        [0] = "Garr",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [3] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [4] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [5] = { "Square", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
        [9] = { "Moon", "-", "-", "-", "-", "-", "-" }
    },
    ['domo'] = {
        [0] = "Majordomo",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [3] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [4] = { "Triangle", "-", "-", "-", "-", "-", "-" },
        [5] = { "Square", "-", "-", "-", "-", "-", "-" },
        [6] = { "Diamond", "-", "-", "-", "-", "-", "-" },
        [7] = { "Circle", "-", "-", "-", "-", "-", "-" },
        [8] = { "Star", "-", "-", "-", "-", "-", "-" },
        [9] = { "Moon", "-", "-", "-", "-", "-", "-" }
    },
    ['rag'] = {
        [0] = "Ragnaros",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Melee", "-", "-", "-", "-", "-", "-" },
        [3] = { "Ranged", "-", "-", "-", "-", "-", "-" },
    },
    ['razorgore'] = {
        [0] = "Razorgore",
        [1] = { "Left", "-", "-", "-", "-", "-", "-" },
        [2] = { "Left", "-", "-", "-", "-", "-", "-" },
        [3] = { "Left", "-", "-", "-", "-", "-", "-" },
        [4] = { "Right", "-", "-", "-", "-", "-", "-" },
        [5] = { "Right", "-", "-", "-", "-", "-", "-" },
        [6] = { "Right", "-", "-", "-", "-", "-", "-" },
    },
    ['vael'] = {
        [0] = "Vaelastrasz",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Group 1", "-", "-", "-", "-", "-", "-" },
        [3] = { "Group 2", "-", "-", "-", "-", "-", "-" },
        [4] = { "Group 3", "-", "-", "-", "-", "-", "-" },
        [5] = { "Group 4", "-", "-", "-", "-", "-", "-" },
        [6] = { "Group 5", "-", "-", "-", "-", "-", "-" },
        [7] = { "Group 6", "-", "-", "-", "-", "-", "-" },
        [8] = { "Group 7", "-", "-", "-", "-", "-", "-" },
        [9] = { "Group 8", "-", "-", "-", "-", "-", "-" },
    },
    ['lashlayer'] = {
        [0] = "Lashlayer",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [3] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [4] = { "BOSS", "-", "-", "-", "-", "-", "-" },
    },
    ['chromaggus'] = {
        [0] = "Chromaggus",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Dispels", "-", "-", "-", "-", "-", "-" },
        [3] = { "Dispels", "-", "-", "-", "-", "-", "-" },
        [4] = { "Enrage", "-", "-", "-", "-", "-", "-" },
    },
    ['nef'] = {
        [0] = "Nefarian",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Left", "-", "-", "-", "-", "-", "-" },
        [3] = { "Left", "-", "-", "-", "-", "-", "-" },
        [4] = { "Right", "-", "-", "-", "-", "-", "-" },
        [5] = { "Right", "-", "-", "-", "-", "-", "-" },
    },
    ['skeram'] = {
        [0] = "Skeram",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Left", "-", "-", "-", "-", "-", "-" },
        [3] = { "Right", "-", "-", "-", "-", "-", "-" },
        [4] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [5] = { "Left", "-", "-", "-", "-", "-", "-" },
        [6] = { "Right", "-", "-", "-", "-", "-", "-" },
    },
    ['bugtrio'] = {
        [0] = "Bug Trio",
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Diamond", "-", "-", "-", "-", "-", "-" },
    },
    ['sartura'] = {
        [0] = "Sartura",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [3] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [4] = { "Square", "-", "-", "-", "-", "-", "-" },
    },
    ['fankriss'] = {
        [0] = "Fankriss",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "North", "-", "-", "-", "-", "-", "-" },
        [3] = { "East", "-", "-", "-", "-", "-", "-" },
        [4] = { "West", "-", "-", "-", "-", "-", "-" },
    },
    ['huhu'] = {
        [0] = "Huhuran",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [3] = { "Melee", "-", "-", "-", "-", "-", "-" },
        [4] = { "Melee", "-", "-", "-", "-", "-", "-" },
    },
    ['twins'] = {
        [0] = "Twin Emps",
        [1] = { "Left", "-", "-", "-", "-", "-", "-" },
        [2] = { "Left", "-", "-", "-", "-", "-", "-" },
        [3] = { "Right", "-", "-", "-", "-", "-", "-" },
        [4] = { "Right", "-", "-", "-", "-", "-", "-" },
        [5] = { "Adds", "-", "-", "-", "-", "-", "-" },
        [6] = { "Adds", "-", "-", "-", "-", "-", "-" },
    },
    ['anub'] = {
        [0] = "Anub'rekhan",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [3] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [4] = { "Raid", "-", "-", "-", "-", "-", "-" },
    },
    ['faerlina'] = {
        [0] = "Faerlina",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [3] = { "Adds", "-", "-", "-", "-", "-", "-" },
        [4] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [5] = { "Cross", "-", "-", "-", "-", "-", "-" },
    },
    ['maexxna'] = {
        [0] = "Maexxna",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [3] = { "Wall", "-", "-", "-", "-", "-", "-" },
        [4] = { "Wall", "-", "-", "-", "-", "-", "-" },
    },
    ['noth'] = {
        [0] = "Noth",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "NorthWest", "-", "-", "-", "-", "-", "-" },
        [3] = { "SouthWest", "-", "-", "-", "-", "-", "-" },
        [4] = { "NorthEast", "-", "-", "-", "-", "-", "-" },
    },
    ['heigan'] = {
        [0] = "Heigan",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Melee", "-", "-", "-", "-", "-", "-" },
        [3] = { "Dispels", "-", "-", "-", "-", "-", "-" },
    },
    ['raz'] = {
        [0] = "Razuvious",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [3] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [4] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [5] = { "Square", "-", "-", "-", "-", "-", "-" },
    },
    ['gothik'] = {
        [0] = "Gothik",
        [1] = { "Living", "-", "-", "-", "-", "-", "-" },
        [2] = { "Living", "-", "-", "-", "-", "-", "-" },
        [3] = { "Dead", "-", "-", "-", "-", "-", "-" },
        [4] = { "Dead", "-", "-", "-", "-", "-", "-" },
    },
    ['4h'] = {
        [0] = "Four Horsemen",
        [1] = { "Skull", "-", "-", "-", "-", "-", "-" },
        [2] = { "Cross", "-", "-", "-", "-", "-", "-" },
        [3] = { "Moon", "-", "-", "-", "-", "-", "-" },
        [4] = { "Square", "-", "-", "-", "-", "-", "-" },
    },
    ['patchwerk'] = {
        [0] = "Patchwerk",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Soaker", "-", "-", "-", "-", "-", "-" },
        [3] = { "Soaker", "-", "-", "-", "-", "-", "-" },
        [4] = { "Soaker", "-", "-", "-", "-", "-", "-" },
    },
    ['grobulus'] = {
        [0] = "Grobbulus",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Melee", "-", "-", "-", "-", "-", "-" },
        [3] = { "Dispells", "-", "-", "-", "-", "-", "-" },
    },
    ['gluth'] = {
        [0] = "Gluth",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Adds", "-", "-", "-", "-", "-", "-" },
    },
    ['thaddius'] = {
        [0] = "Thaddius",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Left", "-", "-", "-", "-", "-", "-" },
        [3] = { "Left", "-", "-", "-", "-", "-", "-" },
        [4] = { "Right", "-", "-", "-", "-", "-", "-" },
        [5] = { "Right", "-", "-", "-", "-", "-", "-" },
    },
    ['saph'] = {
        [0] = "Sapphiron",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [3] = { "Group 1", "-", "-", "-", "-", "-", "-" },
        [4] = { "Group 2", "-", "-", "-", "-", "-", "-" },
        [5] = { "Group 3", "-", "-", "-", "-", "-", "-" },
        [6] = { "Group 4", "-", "-", "-", "-", "-", "-" },
        [7] = { "Group 5", "-", "-", "-", "-", "-", "-" },
        [8] = { "Group 6", "-", "-", "-", "-", "-", "-" },
        [9] = { "Group 7", "-", "-", "-", "-", "-", "-" },
        [10] = { "Group 8", "-", "-", "-", "-", "-", "-" },
    },
    ['kt'] = {
        [0] = "Kel'Thuzad",
        [1] = { "BOSS", "-", "-", "-", "-", "-", "-" },
        [2] = { "Raid", "-", "-", "-", "-", "-", "-" },
    },

}

TWA.raid = {
    ["WARRIOR"] = {},
    ["PALADIN"] = {},
    ["DRUID"] = {},
    ["WARLOCK"] = {},
    ["MAGE"] = {},
    ["PRIEST"] = {},
    ["ROGUE"] = {},
    ["SHAMAN"] = {},
    ["HUNTER"] = {},
}

TWA.classColors = {
    ["WARRIOR"] = { r = 0.78, g = 0.61, b = 0.43, c = "|cffc79c6e" },
    ["MAGE"] = { r = 0.41, g = 0.8, b = 0.94, c = "|cff69ccf0" },
    ["ROGUE"] = { r = 1, g = 0.96, b = 0.41, c = "|cfffff569" },
    ["DRUID"] = { r = 1, g = 0.49, b = 0.04, c = "|cffff7d0a" },
    ["HUNTER"] = { r = 0.67, g = 0.83, b = 0.45, c = "|cffabd473" },
    ["SHAMAN"] = { r = 0.14, g = 0.35, b = 1.0, c = "|cff0070de" },
    ["PRIEST"] = { r = 1, g = 1, b = 1, c = "|cffffffff" },
    ["WARLOCK"] = { r = 0.58, g = 0.51, b = 0.79, c = "|cff9482c9" },
    ["PALADIN"] = { r = 0.96, g = 0.55, b = 0.73, c = "|cfff58cba" },
}

TWA.marks = {
    ['Star'] = TWA.classColors["ROGUE"].c,
    ['Circle'] = TWA.classColors["DRUID"].c,
    ['Diamond'] = TWA.classColors["PALADIN"].c,
    ['Triangle'] = TWA.classColors["HUNTER"].c,
    ['Moon'] = '|cffffffff',
    ['Square'] = TWA.classColors["MAGE"].c,
    ['Cross'] = '|cffff0000',
    ['Skull'] = '|cffffffff',
}

TWA.sides = {
    --if changed also change in buildTargetsDropdown !
    ['Left'] = TWA.classColors["WARLOCK"].c,
    ['Right'] = TWA.classColors["MAGE"].c,
}

TWA.coords = {
    --if changed also change in buildTargetsDropdown !
    ['North'] = '|cffffffff',
    ['South'] = '|cffffffff',
    ['East'] = '|cffffffff',
    ['West'] = '|cffffffff',
    ['NorthWest'] = TWA.classColors["ROGUE"].c,
    ['NorthEast'] = TWA.classColors["ROGUE"].c,
    ['SouthEast'] = TWA.classColors["ROGUE"].c,
    ['SouthWest'] = TWA.classColors["ROGUE"].c,
}

TWA.misc = {
    ['Raid'] = TWA.classColors["SHAMAN"].c,
    ['Melee'] = TWA.classColors["ROGUE"].c,
    ['Ranged'] = TWA.classColors["MAGE"].c,
    ['Adds'] = TWA.classColors["PALADIN"].c,
    ['BOSS'] = '|cffff3333',
    ['Enrage'] = '|cffff7777',
    ['Wall'] = TWA.classColors["HUNTER"].c,
    ['Living'] = TWA.classColors["WARRIOR"].c,
    ['Dead'] = TWA.classColors["DRUID"].c,
    ['Dispels'] = TWA.classColors["MAGE"].c,
    ['Soaker'] = TWA.classColors["DRUID"].c,
}

TWA.groups = {
    [1] = TWA.classColors["PRIEST"].c,
    [2] = TWA.classColors["PRIEST"].c,
    [3] = TWA.classColors["PRIEST"].c,
    [4] = TWA.classColors["PRIEST"].c,
    [5] = TWA.classColors["PRIEST"].c,
    [6] = TWA.classColors["PRIEST"].c,
    [7] = TWA.classColors["PRIEST"].c,
    [8] = TWA.classColors["PRIEST"].c,
}

function TWA.OnLoad()
    TWA_Main:RegisterEvent("VARIABLES_LOADED")
    TWA_Main:RegisterEvent("RAID_ROSTER_UPDATE")
    TWA_Main:RegisterEvent("CHAT_MSG_ADDON")
    TWA_Main:RegisterEvent("CHAT_MSG_WHISPER")
    TWA_Main:RegisterForDrag("LeftButton")
    TWA_Main:SetMovable(1)
    TWA_Main:SetUserPlaced(true)
end

function TWA.VARIABLES_LOADED()
    twadebug(event)
    twaprint("TWA Loaded")
    if not TWA_PRESETS then TWA_PRESETS = {} end
    if not TWA_DATA then TWA_DATA = {{ '-', '-', '-', '-', '-', '-', '-' }} end
    TWA.data = TWA_DATA
    TWA.fillRaidData()
    TWA.PopulateTWA()
    tinsert(UISpecialFrames, "TWA_Main") -- makes window close with Esc key
    TWA_Minimap:ClearAllPoints()
    TWA_Minimap:SetPoint('CENTER', UIParent, 'BOTTOMLEFT', unpack(TWA_POSITION or {TWA_Minimap:GetCenter()}))
end

function TWA.RAID_ROSTER_UPDATE()
    twadebug(event)
    TWA.fillRaidData()
    TWA.PopulateTWA()
end

function TWA.CHAT_MSG_ADDON()
    if arg1 == "TWA" then
        twadebug(arg4, 'says:', arg2)
        TWA.handleSync(arg2)
    elseif arg1 == "QH" then
        twadebug(arg4, 'says:', arg2)
        TWA.handleQHSync(arg2, arg4)
    end
end

function TWA.CHAT_MSG_WHISPER()
    if arg1 ~= 'heal' then return end
    twadebug(event)
    local lineToSend = ''
    for _, row in pairs(TWA.data) do
        local mark = ''
        local tank = ''
        for i, cell in pairs(row) do
            if i == 1 then
                mark = cell
                tank = mark
            end
            if i == 2 or i == 3 or i == 4 then
                if cell ~= '-' then
                    tank = ''
                end
            end
            if i == 2 or i == 3 or i == 4 then
                if cell ~= '-' then
                    tank = tank .. cell .. ' '
                end
            end
            if arg2 == cell then
                if i == 2 or i == 3 or i == 4 then
                    if lineToSend == '' then
                        lineToSend = 'You are assigned to ' .. mark
                    else
                        lineToSend = lineToSend .. ' and ' .. mark
                    end
                end
                if i == 5 or i == 6 or i == 7 then
                    if lineToSend == '' then
                        lineToSend = 'You are assigned to Heal ' .. tank
                    else
                        lineToSend = lineToSend .. ' and ' .. tank
                    end
                end
            end
        end
    end
    if lineToSend == '' then
        SendChatMessage("You are not assigned.", "WHISPER", nil, arg2)
    else
        SendChatMessage(lineToSend, "WHISPER", nil, arg2)
    end
end

function TWA.markOrPlayerUsed(markOrPlayer)
    for row, data in pairs(TWA.data) do
        for _, as in pairs(data) do
            if as == markOrPlayer then
                return true
            end
        end
    end
    return false
end

function TWA.fillRaidData()
    twadebug('fill raid data')
    for k in pairs(TWA.raid) do wipe(TWA.raid[k]) end
    for i = 1, GetNumRaidMembers() do
        local name = GetRaidRosterInfo(i)
        if name then
            local _, class = UnitClass('raid' .. i)
            table.insert(TWA.raid[class], name)
        end
    end
    for k in pairs(TWA.raid) do table.sort(TWA.raid[k]) end
end

function TWA.isPlayerOffline(player)
    for i = 1, GetNumRaidMembers() do
        local name, rank, subgroup, level, class, fileName, zone, online, isDead = GetRaidRosterInfo(i)
        if name == player then
            return not online
        end
    end
    return false
end

function TWA.handleSync(text)
    if string.find(text, 'LoadTemplate=', 1, true) then
        local template = string.gsub(text, "LoadTemplate=", "")
        
        if not template then return end
        
        TWA.loadTemplate(template, true)
        return
    end

    if string.find(text, 'RemRow=', 1, true) then
        local id = tonumber((string.gsub(text, "RemRow=", "")))
        if not id then return end
        
        if TWA.data[id + 1] then TWA.data[id] = TWA.data[id + 1] end
        
        local last
        for i in pairs(TWA.data) do
            if i > id then
                if TWA.data[i + 1] then TWA.data[i] = TWA.data[i + 1] end
            end
            last = i
        end
        TWA.data[last] = nil
        TWA.PopulateTWA()
        return
    end
    
    if string.find(text, 'ChangeCell=', 1, true) then
        local info = strsplit(text, '=')
        local xy, to = tonumber(info[2]), info[3]
        
        if not xy and to then return end
        
        local x = math.floor(xy / 100)
        local y = xy - x * 100
        
        if not TWA.data[x] then
            TWA.data[table.getn(TWA.data) + 1] = { '-', '-', '-', '-', '-', '-', '-' }
        end
        
        TWA.data[x][y] = to == 'Clear' and '-' or to
        TWA.PopulateTWA()
        return
    end
    
    if string.find(text, 'Reset', 1, true) then
        for row in pairs(TWA.data) do
            if TWA.rows[row] then TWA.rows[row]:Hide() end
        end
        
        TWA.data = {{ '-', '-', '-', '-', '-', '-', '-' }}
        TWA.PopulateTWA()
        return
    end
    
    if string.find(text, 'AddLine', 1, true) then
        TWA.data[table.getn(TWA.data) + 1] = { '-', '-', '-', '-', '-', '-', '-' }
        TWA.PopulateTWA()
        return
    end
end

function TWA.handleQHSync(text, sender)
    if sender == me then return end
    if not string.find(text, 'RequestRoster', 1, true) then return end
    local roster
    local tanks = 'Tanks='
    local healers = 'Healers='
    -- QH roster request
    for index, data in pairs(TWA.data) do -- build roster string
        for i, name in data do
            if i == 2 or i == 3 or i == 4 then
                if name ~= '-' then
                    if string.len(tanks) == 6 then -- skip ',' delimiter if this is the first tank entry
                        tanks = tanks .. name
                    else
                        tanks = tanks .. "," .. name
                    end
                end
            end
            if i == 5 or i == 6 or i == 7 then
                if name ~= '-' then
                    if string.len(healers) == 8 then -- skip ',' delimiter if this is the first healer entry
                        healers = healers .. name
                    else
                        healers = healers .. "," .. name
                    end
                end
            end
        end
    end
    roster = tanks .. ";" .. healers;
    SendAddonMessage("TWA", roster, "RAID") -- transmit roster
end

function TWA.ChangeCellSend(xy, to)
    SendAddonMessage("TWA", "ChangeCell=" .. xy .. "=" .. to .. "=0", "RAID")
    CloseDropDownMenus()
end

function TWA.PopulateTWA()
    twadebug('PopulateTWA')

    for i = 1, getn(TWA.rows) do
        if TWA.rows[i]:IsShown() then TWA.rows[i]:Hide() end
    end

    for row, data in pairs(TWA.data) do
        if not TWA.rows[row] then
            TWA.rows[row] = CreateFrame('Frame', 'TWRow' .. row, TWA_Main, 'TWRow')
        end

        TWA.rows[row]:Show()
        TWA.rows[row]:SetBackdropColor(0, 0, 0, .2);
        TWA.rows[row]:SetPoint("TOP", TWA_Main, "TOP", 0, -25 - row * 21)
        
        if not TWA.cells[row] then TWA.cells[row] = {} end

        _G['TWRow' .. row .. 'CloseRow']:SetID(row)

        for col, text in ipairs(data) do
            if not TWA.cells[row][col] then
                TWA.cells[row][col] = CreateFrame('Button', 'TWCell' .. row .. col, TWA.rows[row], 'TWCell')
            end

            TWA.cells[row][col]:SetPoint("LEFT", TWA.rows[row], "LEFT", -82 + col * 82, 0)
            TWA.cells[row][col]:SetID((row * 100) + col)

            local color = TWA.classColors["PRIEST"].c
            TWA.cells[row][col]:SetBackdropColor(.2, .2, .2, .7);
            for class, members in pairs(TWA.raid) do
                for _, raidMember in pairs(members) do
                    if raidMember == text then
                        color = TWA.classColors[class].c
                        local r = TWA.classColors[class].r
                        local g = TWA.classColors[class].g
                        local b = TWA.classColors[class].b
                        TWA.cells[row][col]:SetBackdropColor(r, g, b, .7);
                        break
                    end
                end
            end

            if TWA.marks[text] then color = TWA.marks[text] end
            if TWA.sides[text] then color = TWA.sides[text] end
            if TWA.coords[text] then color = TWA.coords[text] end
            if TWA.misc[text] then color = TWA.misc[text] end
            -- if TWA.groups[text] then color = TWA.groups[text] end
            
            if text == '-' then text = '' end
            if TWA.isPlayerOffline(text) then color = RED_FONT_COLOR_CODE end
            _G['TWCell' .. row .. col .. 'Text']:SetText(color .. text)
            
            local icon = _G['TWCell' .. row .. col .. 'Icon']
            icon:Hide()
            if col == 1 then
                if text == 'Skull' then
                    SetRaidTargetIconTexture(icon, 8)
                    icon:Show()
                elseif text == 'Cross' then
                    SetRaidTargetIconTexture(icon, 7)
                    icon:Show()
                elseif text == 'Square' then
                    SetRaidTargetIconTexture(icon, 6)
                    icon:Show()
                elseif text == 'Moon' then
                    SetRaidTargetIconTexture(icon, 5)
                    icon:Show()
                elseif text == 'Triangle' then
                    SetRaidTargetIconTexture(icon, 4)
                    icon:Show()
                elseif text == 'Diamond' then
                    SetRaidTargetIconTexture(icon, 3)
                    icon:Show()
                elseif text == 'Circle' then
                    SetRaidTargetIconTexture(icon, 2)
                    icon:Show()
                elseif text == 'Star' then
                    SetRaidTargetIconTexture(icon, 1)
                    icon:Show()
                end
            end
        end
    end

    TWA_Main:SetHeight(50 + table.getn(TWA.data) * 21)
    TWA_DATA = TWA.data
end

local function buildTargetsDropdown()
    local info = UIDropDownMenu_CreateInfo()
    
    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
        info.text = "Target"
        info.isTitle = true
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
        info.isTitle = nil
        info.disabled = nil

        info.text = "Marks"
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'marks'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

        info.text = "Sides"
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'sides'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

        info.text = "Coords"
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'coords'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

        info.text = "Misc"
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'misc'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

        info.text = "Groups"
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'groups'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

        info.text = "Clear"
        info.disabled = false
        info.isTitle = false
        info.notCheckable = true
        info.hasArrow = nil
        info.func = TWA.ChangeCellSend
        info.arg1 = TWA.currentRow * 100 + TWA.currentCell
        info.arg2 = 'Clear'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
    end

    if UIDROPDOWNMENU_MENU_LEVEL == 2 then
        if UIDROPDOWNMENU_MENU_VALUE == 'marks' then
            info.text = "Marks"
            info.isTitle = true
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            info.isTitle = nil
            info.disabled = nil
            
            for mark, color in pairs(TWA.marks) do
                info.text = color .. mark
                info.checked = TWA.markOrPlayerUsed(mark)
                info.icon = 'Interface\\TargetingFrame\\UI-RaidTargetingIcons'

                if mark == 'Skull' then
                    info.tCoordLeft = 0.75
                    info.tCoordRight = 1
                    info.tCoordTop = 0.25
                    info.tCoordBottom = 0.5
                elseif mark == 'Cross' then
                    info.tCoordLeft = 0.5
                    info.tCoordRight = 0.75
                    info.tCoordTop = 0.25
                    info.tCoordBottom = 0.5
                elseif mark == 'Square' then
                    info.tCoordLeft = 0.25
                    info.tCoordRight = 0.5
                    info.tCoordTop = 0.25
                    info.tCoordBottom = 0.5
                elseif mark == 'Moon' then
                    info.tCoordLeft = 0
                    info.tCoordRight = 0.25
                    info.tCoordTop = 0.25
                    info.tCoordBottom = 0.5
                elseif mark == 'Triangle' then
                    info.tCoordLeft = 0.75
                    info.tCoordRight = 1
                    info.tCoordTop = 0
                    info.tCoordBottom = 0.25
                elseif mark == 'Diamond' then
                    info.tCoordLeft = 0.5
                    info.tCoordRight = 0.75
                    info.tCoordTop = 0
                    info.tCoordBottom = 0.25
                elseif mark == 'Circle' then
                    info.tCoordLeft = 0.25
                    info.tCoordRight = 0.5
                    info.tCoordTop = 0
                    info.tCoordBottom = 0.25
                elseif mark == 'Star' then
                    info.tCoordLeft = 0
                    info.tCoordRight = 0.25
                    info.tCoordTop = 0
                    info.tCoordBottom = 0.25
                end

                info.func = TWA.ChangeCellSend
                info.arg1 = TWA.currentRow * 100 + TWA.currentCell
                info.arg2 = mark
                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            end
        end

        if UIDROPDOWNMENU_MENU_VALUE == 'sides' then
            info.text = "Sides"
            info.isTitle = true
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            info.isTitle = nil
            info.disabled = nil

            info.text = TWA.sides['Left'] .. 'Left'
            info.checked = TWA.markOrPlayerUsed('Left')
            info.func = TWA.ChangeCellSend
            info.arg1 = TWA.currentRow * 100 + TWA.currentCell
            info.arg2 = 'Left'
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = TWA.sides['Right'] .. 'Right'
            info.checked = TWA.markOrPlayerUsed('Right')
            info.func = TWA.ChangeCellSend
            info.arg1 = TWA.currentRow * 100 + TWA.currentCell
            info.arg2 = 'Right'
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
        end

        if UIDROPDOWNMENU_MENU_VALUE == 'coords' then
            info.text = "Coords"
            info.isTitle = true
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            info.isTitle = nil
            info.disabled = nil
            
            info.text = TWA.coords['North'] .. 'North'
            info.checked = TWA.markOrPlayerUsed('North')
            info.func = TWA.ChangeCellSend
            info.arg1 = TWA.currentRow * 100 + TWA.currentCell
            info.arg2 = 'North'
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = TWA.coords['South'] .. 'South'
            info.checked = TWA.markOrPlayerUsed('South')
            info.func = TWA.ChangeCellSend
            info.arg1 = TWA.currentRow * 100 + TWA.currentCell
            info.arg2 = 'South'
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = TWA.coords['East'] .. 'East'
            info.checked = TWA.markOrPlayerUsed('East')
            info.func = TWA.ChangeCellSend
            info.arg1 = TWA.currentRow * 100 + TWA.currentCell
            info.arg2 = 'East'
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            
            info.text = TWA.coords['West'] .. 'West'
            info.checked = TWA.markOrPlayerUsed('West')
            info.func = TWA.ChangeCellSend
            info.arg1 = TWA.currentRow * 100 + TWA.currentCell
            info.arg2 = 'West'
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
        end

        if UIDROPDOWNMENU_MENU_VALUE == 'misc' then
            info.text = "Misc"
            info.isTitle = true
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            info.isTitle = nil
            info.disabled = nil

            for mark, color in pairs(TWA.misc) do
                info.text = color .. mark
                info.checked = TWA.markOrPlayerUsed(mark)
                info.func = TWA.ChangeCellSend
                info.arg1 = TWA.currentRow * 100 + TWA.currentCell
                info.arg2 = mark
                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            end
        end

        if UIDROPDOWNMENU_MENU_VALUE == 'groups' then
            info.text = "Groups"
            info.isTitle = true
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            info.isTitle = nil
            info.disabled = nil

            for i = 1, getn(TWA.groups) do
                local mark = GROUP.." "..i
                info.text = mark
                info.checked = TWA.markOrPlayerUsed(mark)
                info.func = TWA.ChangeCellSend
                info.arg1 = TWA.currentRow * 100 + TWA.currentCell
                info.arg2 = mark
                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            end
        end
    end
end

local function buildTanksDropdown()
    local info = UIDropDownMenu_CreateInfo()

    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
        info.text = "Tanks"
        info.isTitle = true
        UIDropDownMenu_AddButton(info);
        info.isTitle = nil
        info.disabled = nil

        info.text = TWA.classColors["WARRIOR"].c .. 'Warriors'
        info.notCheckable = true
        info.hasArrow = true
        info.value = "WARRIOR"
        UIDropDownMenu_AddButton(info);

        info.text = TWA.classColors["DRUID"].c .. 'Druids'
        info.notCheckable = true
        info.hasArrow = true
        info.value = "DRUID"
        UIDropDownMenu_AddButton(info);

        info.text = TWA.classColors["PALADIN"].c .. 'Paladins'
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'PALADIN'
        UIDropDownMenu_AddButton(info);

        info.text = TWA.classColors["WARLOCK"].c .. 'Warlocks'
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'WARLOCK'
        UIDropDownMenu_AddButton(info);

        info.text = TWA.classColors["MAGE"].c .. 'Mages'
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'MAGE'
        UIDropDownMenu_AddButton(info);

        info.text = TWA.classColors["PRIEST"].c .. 'Priests'
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'PRIEST'
        UIDropDownMenu_AddButton(info);

        info.text = TWA.classColors["ROGUE"].c .. 'Rogues'
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'ROGUE'
        UIDropDownMenu_AddButton(info);

        info.text = TWA.classColors["HUNTER"].c .. 'Hunters'
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'HUNTER'
        UIDropDownMenu_AddButton(info);

        info.text = TWA.classColors["SHAMAN"].c .. 'Shamans'
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'SHAMAN'
        UIDropDownMenu_AddButton(info);

        info.text = "Clear"
        info.disabled = false
        info.isTitle = false
        info.hasArrow = nil
        info.notCheckable = true
        info.func = TWA.ChangeCellSend
        info.arg1 = TWA.currentRow * 100 + TWA.currentCell
        info.arg2 = 'Clear'
        UIDropDownMenu_AddButton(info);
    
    elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
        if not TWA.raid[UIDROPDOWNMENU_MENU_VALUE] then return end
        
        for i, tank in pairs(TWA.raid[UIDROPDOWNMENU_MENU_VALUE]) do
            local color = TWA.classColors[UIDROPDOWNMENU_MENU_VALUE].c
            if TWA.isPlayerOffline(tank) then color = GRAY_FONT_COLOR_CODE end

            info.text = color .. tank
            info.checked = TWA.markOrPlayerUsed(tank)
            info.func = TWA.ChangeCellSend
            info.arg1 = TWA.currentRow * 100 + TWA.currentCell
            info.arg2 = tank
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
        end
    end
end

local function buildHealersDropdown()
    local info = UIDropDownMenu_CreateInfo()
    
    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
        info.text = "Healers"
        info.isTitle = true
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
        info.isTitle = nil
        info.disabled = nil
        
        info.text = TWA.classColors["PRIEST"].c .. 'Priests'
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'PRIEST'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

        info.text = TWA.classColors["DRUID"].c .. 'Druids'
        info.notCheckable = true
        info.hasArrow = true
        info.value = "DRUID"
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

        info.text = TWA.classColors["SHAMAN"].c .. 'Shamans'
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'SHAMAN'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

        info.text = TWA.classColors["PALADIN"].c .. 'Paladins'
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'PALADIN'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

        info.text = "Clear"
        info.disabled = false
        info.isTitle = false
        info.hasArrow = nil
        info.notCheckable = true
        info.func = TWA.ChangeCellSend
        info.arg1 = TWA.currentRow * 100 + TWA.currentCell
        info.arg2 = 'Clear'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
    
    elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
        if not TWA.raid[UIDROPDOWNMENU_MENU_VALUE] then return end
        
        for _, healer in pairs(TWA.raid[UIDROPDOWNMENU_MENU_VALUE]) do
            local color = TWA.classColors[UIDROPDOWNMENU_MENU_VALUE].c
            if TWA.isPlayerOffline(healer) then color = GRAY_FONT_COLOR_CODE end

            info.text = color .. healer
            info.checked = TWA.markOrPlayerUsed(healer)
            info.func = TWA.ChangeCellSend
            info.arg1 = TWA.currentRow * 100 + TWA.currentCell
            info.arg2 = healer
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
        end
    end
end

function TWA.Cell_OnClick(id)
    if not (IsRaidLeader() or IsRaidOfficer()) then
        twaprint("You need to be a raid leader or assistant to do that")
        return
    end
    
    TWA.currentRow = math.floor(id / 100)
    TWA.currentCell = id - TWA.currentRow * 100

    -- targets
    if TWA.currentCell == 1 then
        UIDropDownMenu_Initialize(TWADropDown, buildTargetsDropdown, "MENU");
        ToggleDropDownMenu(1, nil, TWADropDown, "cursor", 2, 3);
    end

    -- tanks
    if TWA.currentCell == 2 or TWA.currentCell == 3 or TWA.currentCell == 4 then
        UIDropDownMenu_Initialize(TWADropDown, buildTanksDropdown, "MENU");
        ToggleDropDownMenu(1, nil, TWADropDown, "cursor", 2, 3);
    end

    -- healers
    if TWA.currentCell == 5 or TWA.currentCell == 6 or TWA.currentCell == 7 then
        UIDropDownMenu_Initialize(TWADropDown, buildHealersDropdown, "MENU");
        ToggleDropDownMenu(1, nil, TWADropDown, "cursor", 2, 3);
    end

    if IsControlKeyDown() then
        CloseDropDownMenus()
        TWA.ChangeCellSend(TWA.currentRow * 100 + TWA.currentCell, "Clear")
    end
end

function TWA.Cell_OnEnter(id)
    local index = math.floor(id / 100)
    if id < 100 then index = id end
    _G['TWRow' .. index]:SetBackdropColor(1, 1, 1, .2)
end

function TWA.Cell_OnLeave(id)
    local index = math.floor(id / 100)
    if id < 100 then index = id end
   _G['TWRow' .. index]:SetBackdropColor(0, 0, 0, .2)
end

function TWA.AddLine_OnClick()
    if not (IsRaidLeader() or IsRaidOfficer()) then
        twaprint("You need to be a raid leader or assistant to do that")
        return
    end
    SendAddonMessage("TWA", "AddLine", "RAID")
end

function TWA.Announce_OnClick()
    if not (IsRaidLeader() or IsRaidOfficer()) then
        twaprint("You need to be a raid leader or assistant to do that")
        return
    end
    SendChatMessage("======= RAID ASSIGNMENTS =======", "RAID_WARNING")

    for _, data in pairs(TWA.data) do

        local line = ''
        local dontPrintLine = true
        for i, name in data do
            if i > 1 then
                dontPrintLine = dontPrintLine and name == '-'
            end

            local separator = ''
            if i == 1 then
                separator = ' : '
            end
            if i == 4 then
                separator = ' || Healers: '
            end

            if name == '-' then
                name = ''
            end

            if TWA.loadedTemplate == '4h' then
                if name ~= '' and i >= 5 then
                    name = '[' .. i - 4 .. ']' .. name
                end
            end

            line = line .. name .. ' ' .. separator
        end

        if not dontPrintLine then
            SendChatMessage(line, "RAID")
        end
    end
    SendChatMessage("Not assigned, heal the raid. Whisper me 'heal' if you forget your assignment.", "RAID")
end

function TWA.RemoveRow_OnClick(id)
    if not (IsRaidLeader() or IsRaidOfficer()) then
        twaprint("You need to be a raid leader or assistant to do that")
        return
    end
    SendAddonMessage("TWA", "RemRow=" .. id, "RAID")
end

function TWA.Reset_OnClick()
    if not (IsRaidLeader() or IsRaidOfficer()) then
        twaprint("You need to be a raid leader or assistant to do that")
        return
    end
    SendAddonMessage("TWA", "Reset", "RAID")
end

local function buildTemplatesDropdown()
    local info = UIDropDownMenu_CreateInfo()

    if UIDROPDOWNMENU_MENU_LEVEL == 1 then
        info.text = "Templates"
        info.isTitle = true
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
        info.isTitle = nil
        info.disabled = nil

        info.text = "Trash"
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'trash'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

        info.text = "Molten Core"
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'mc'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

        info.text = "Blackwing Lair"
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'bwl'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

        info.text = "Ahn\'Quiraj"
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'aq40'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

        info.text = "Naxxramas"
        info.notCheckable = true
        info.hasArrow = true
        info.value = 'naxx'
        UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
    
    elseif UIDROPDOWNMENU_MENU_LEVEL == 2 then
        if UIDROPDOWNMENU_MENU_VALUE == 'trash' then
            for i = 1, 5 do
                info.text = "Trash #" .. i
                info.func = TWA.loadTemplate
                info.arg1 = 'trash' .. i
                info.arg2 = false
                info.checked = TWA.loadedTemplate == info.arg1
                UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            end
        
        elseif UIDROPDOWNMENU_MENU_VALUE == 'mc' then
            info.text = "Gaar"
            info.func = TWA.loadTemplate
            info.arg1 = 'gaar'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Majordomo"
            info.func = TWA.loadTemplate
            info.arg1 = 'domo'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Ragnaros"
            info.func = TWA.loadTemplate
            info.arg1 = 'rag'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
        
        elseif UIDROPDOWNMENU_MENU_VALUE == 'bwl' then
            info.text = "Razorgore"
            info.func = TWA.loadTemplate
            info.arg1 = 'razorgore'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Vaelastrasz"
            info.func = TWA.loadTemplate
            info.arg1 = 'vael'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Lashlayer"
            info.func = TWA.loadTemplate
            info.arg1 = 'lashlayer'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Chromaggus"
            info.func = TWA.loadTemplate
            info.arg1 = 'chromaggus'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Nefarian"
            info.func = TWA.loadTemplate
            info.arg1 = 'nef'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
        
        elseif UIDROPDOWNMENU_MENU_VALUE == 'aq40' then
            info.text = "The Prophet Skeram"
            info.func = TWA.loadTemplate
            info.arg1 = 'skeram'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Bug Trio"
            info.func = TWA.loadTemplate
            info.arg1 = 'bugtrio'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Battleguard Sartura"
            info.func = TWA.loadTemplate
            info.arg1 = 'sartura'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Fankriss"
            info.func = TWA.loadTemplate
            info.arg1 = 'fankriss'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Huhuran"
            info.func = TWA.loadTemplate
            info.arg1 = 'huhu'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Twin Emps"
            info.func = TWA.loadTemplate
            info.arg1 = 'twins'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
        
        elseif UIDROPDOWNMENU_MENU_VALUE == 'naxx' then
            info.text = "Anub'rekhan"
            info.func = TWA.loadTemplate
            info.arg1 = 'anub'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Faerlina"
            info.func = TWA.loadTemplate
            info.arg1 = 'faerlina'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Maexxna"
            info.func = TWA.loadTemplate
            info.arg1 = 'maexxna'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = ""
            info.disabled = true
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            info.disabled = nil

            info.text = "Noth"
            info.func = TWA.loadTemplate
            info.arg1 = 'noth'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Heigan"
            info.func = TWA.loadTemplate
            info.arg1 = 'heigan'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = ""
            info.disabled = true
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            info.disabled = nil

            info.text = "Razuvious"
            info.func = TWA.loadTemplate
            info.arg1 = 'raz'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Gothik"
            info.func = TWA.loadTemplate
            info.arg1 = 'gothik'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Four Horsemen"
            info.func = TWA.loadTemplate
            info.arg1 = '4h'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = ""
            info.disabled = true
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            info.disabled = nil

            info.text = "Patchwerk"
            info.func = TWA.loadTemplate
            info.arg1 = 'patchwerk'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Grobbulus"
            info.func = TWA.loadTemplate
            info.arg1 = 'grobulus'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Gluth"
            info.func = TWA.loadTemplate
            info.arg1 = 'gluth'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Thaddius"
            info.func = TWA.loadTemplate
            info.arg1 = 'thaddius'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = ""
            info.disabled = true
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
            info.disabled = nil

            info.text = "Sapphiron"
            info.func = TWA.loadTemplate
            info.arg1 = 'saph'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)

            info.text = "Kel'Thuzad"
            info.func = TWA.loadTemplate
            info.arg1 = 'kt'
            info.arg2 = false
            info.checked = TWA.loadedTemplate == info.arg1
            UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
        end
    end
end

function TWA.Templates_OnClick()
    if not (IsRaidLeader() or IsRaidOfficer()) then
        twaprint("You need to be a raid leader or assistant to do that")
        return
    end
    UIDropDownMenu_Initialize(TWADropDown, buildTemplatesDropdown, "MENU");
    ToggleDropDownMenu(1, nil, TWADropDown, TWA_MainTemplates, 0, 0);
end

function TWA.LoadPreset_OnClick()
    if not (IsRaidLeader() or IsRaidOfficer()) then
        twaprint("You need to be a raid leader or assistant to do that")
        return
    end
    
    if not TWA.loadedTemplate then
        twaprint('Please load a template first.')
        return
    end
    
    TWA.loadTemplate(TWA.loadedTemplate)

    if not TWA_PRESETS[TWA.loadedTemplate] then
        twaprint('No preset saved for |cff69ccf0' .. TWA.loadedTemplate)
        return
    end

    for index, data in pairs(TWA_PRESETS[TWA.loadedTemplate]) do
        for i, name in data do
            if i ~= 1 and name ~= '-' then
                TWA.ChangeCellSend(index * 100 + i, name)
            end
        end
    end
end

function TWA.SavePreset_OnClick()
    if not (IsRaidLeader() or IsRaidOfficer()) then
        twaprint("You need to be a raid leader or assistant to do that")
        return
    end
   
    if not TWA.loadedTemplate then
        twaprint('Please load a template first.')
        return
    end
    
    local preset = {}
    for index, data in pairs(TWA.data) do
        preset[index] = {}
        for i, name in data do
            table.insert(preset[index], name)
        end
    end
    TWA_PRESETS[TWA.loadedTemplate] = preset
    twaprint('Saved preset for |cff69ccf0' .. TWA.loadedTemplate)
end

function TWA.loadTemplate(template, load)
    if not TWA.templates[template] then return false end
    if load then
        TWA.data = {}
        for i, d in ipairs(TWA.templates[template]) do
            TWA.data[i] = d
        end
        TWA.PopulateTWA()
        twaprint('Loaded template |cff69ccf0' .. template)
        TWA_MainTemplates:SetText(TWA.templates[template][0])
        TWA.loadedTemplate = template
        return true
    end
    SendAddonMessage("TWA", "LoadTemplate=" .. template, "RAID")
end
