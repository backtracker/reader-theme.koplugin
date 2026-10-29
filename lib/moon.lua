local DataStorage = require("datastorage")
local LuaSettings = require("luasettings")
local lfs = require("libs/libkoreader-lfs")

-- Moon（月读）设置只读访问，本插件不会写入 Moon 的配置
local moon = {}

local function moon_settings_path(name)
    return DataStorage:getDataDir() .. "/.moon/settings/" .. name .. ".lua"
end

local function is_file(path)
    return lfs.attributes(path, "mode") == "file"
end

local function open_settings(name)
    local path = moon_settings_path(name)
    if not is_file(path) then return nil end
    local ok, settings = pcall(function() return LuaSettings:open(path) end)
    if not ok or not settings then return nil end
    return settings
end

function moon.installed()
    return lfs.attributes(DataStorage:getDataDir() .. "/.moon", "mode") == "directory"
end

function moon.readerWallpaperActive()
    local settings = open_settings("wallpaper")
    if not settings then return false end

    if settings:readSetting("wallpaper_enabled") == false then return false end
    if settings:readSetting("wallpaper_reader") ~= true then return false end

    local image = settings:readSetting("wallpaper_image_reader")
        or settings:readSetting("wallpaper_custom_image")
    if type(image) == "string" and image ~= "" then return true end

    return settings:readSetting("wallpaper_source") == "custom"
end

function moon.replacesNativeBars()
    if not moon.installed() then return false end

    local settings = open_settings("bars")
    -- 未生成配置文件时 Moon 默认接管底部栏
    if not settings then return true end

    return settings:readSetting("book_reader_bottom_bar") ~= false
        and settings:readSetting("book_reader_replace_bottom_bar") ~= false
end

return moon
