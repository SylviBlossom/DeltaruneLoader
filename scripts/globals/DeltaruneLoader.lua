local DeltaruneLoader = {}
local self = DeltaruneLoader

DeltaruneLoader.CHAPTERS = 2


function DeltaruneLoader.init()
    self.saves = {}

    for i = 1, self.CHAPTERS do
        self.saves[i] = {}
    end

    self.path = self.getSaveDirectory()

    if not self.path then
        print("[DeltaruneLoader] Unsupported OS: "..love.system.getOS())
        return
    end
end

function DeltaruneLoader.load(filter)
    if not self.path then
        return false
    end

    filter = filter or {}

    local function loadFile(chapter, slot, completed)
        if self.saves[chapter] and self.saves[chapter][slot] then
            return -- Already loaded
        end

        local file = io.open(self.path.."/filech"..chapter.."_"..(slot-1), "r")

        if file then
            local data_str = file:read("*all")
            file:close()

            local data = Utils.split(data_str, "\n")

            for i = 1, #data do
                data[i] = string.gsub(data[i], "^%s*(.-)%s*$", "%1")
            end

            local slot_id = slot
            if completed then
                slot_id = slot_id - 3
            end

            local save = DeltaruneSave(chapter, slot_id, completed)
            save:parseData(data)

            self.saves[chapter] = self.saves[chapter] or {}
            self.saves[chapter][slot] = save
        end
    end

    for chapter = 1, self.CHAPTERS do
        if filter.chapter == nil or filter.chapter == chapter then
            if filter.completed == nil or filter.completed == false then
                for slot = 1, 3 do
                    if filter.slot == nil or filter.slot == slot then
                        loadFile(chapter, slot, false)
                    end
                end
            end

            if filter.completed == nil or filter.completed == true then
                for slot = 4, 6 do
                    if filter.slot == nil or filter.slot == (slot - 3) then
                        loadFile(chapter, slot, true)
                    end
                end
            end
        end
    end
end

function DeltaruneLoader.getSave(chapter, slot)
    return self.saves[chapter] and self.saves[chapter][slot]
end

function DeltaruneLoader.getCompletion(chapter, slot)
    return self.saves[chapter] and self.saves[chapter][slot + 3]
end

function DeltaruneLoader.getSaveDirectory()
    local os_name = love.system.getOS()

    if os_name == "Windows" then
        return string.gsub(os.getenv("LOCALAPPDATA"), "\\", "/") .. "/Deltarune/"
    elseif os_name == "OS X" then
        return os.getenv("HOME") .. "/Library/Application Support/com.tobyfox.deltarune/"
    elseif os_name == "Linux" then
        -- Tested on: Linux mint, should probably work on all Debian based systems
        -- I know this code is bad

        -- love.filesystem won't read stuff outside of the game
        local function file_exists(file)
            local f = io.open(file, "rb")
            if f then f:close() end
            return f ~= nil
        end

        local home = os.getenv("HOME")
        local winePath = home .. "/.wine/drive_c/users/" .. os.getenv("USER") .. "/Local Settings/Application Data/DELTARUNE/"
        -- I THINK the numbers it is the same in all systems
        -- Source: https://store.steampowered.com/app/1690940 (You will get redirected to deltarune) 
        local steamPath = home .. "/.steam/steam/steamapps/compatdata/1690940/pfx/drive_c/users/steamuser/AppData/Local/DELTARUNE/"

        if file_exists(winePath) then -- Get the path from WINE
            return winePath
        elseif file_exists(steamPath) then -- Get the path from steam
            return steamPath
        end
    end
end


return DeltaruneLoader
