local Event = require("ui/event")
local ReaderTypeset = require("apps/reader/modules/readertypeset")
local ReaderUI = require("apps/reader/readerui")
local Screen = require("device").screen
local Setting = require("lib/setting")
local UIManager = require("ui/uimanager")
local background_color = require("book/background_color")
local common = require("lib/common")
local font_color = require("book/font_color")
local highlight_colors_menu = require("book/highlight_colors")
local link_color = require("book/link_color")
local moon = require("lib/moon")
local progress_bar_colors_menu = require("book/progress_bar_colors")
local progress_bar_roundness_menu = require("book/progress_bar_roundness")
local themes_menu = require("book/themes")

local function refreshCSS()
    if ReaderUI.instance and ReaderUI.instance.rolling then
        UIManager:broadcastEvent(Event:new("ApplyStyleSheet"))
    end
end

local function book_items()
    local items = {
        themes_menu(),
        common.add_separator(background_color.menu()),
        font_color.menu(),
        common.add_separator(link_color.menu()),
        highlight_colors_menu(),
    }

    -- Moon 接管底部栏时原生进度条不会显示，隐藏相关菜单
    if not moon.replacesNativeBars() then
        table.insert(items, progress_bar_colors_menu())
        table.insert(items, progress_bar_roundness_menu())
    end

    return items
end

-- Setting for the fixed page color
local FixedBackgroundColor = Setting("book_background_color_fixed", true)
local FixedFontColor = Setting("book_font_color_fixed", true)
local FixedLinkColor = Setting("book_link_color_fixed", true)

local function recomputeAllColors()
    UIManager:broadcastEvent(Event:new("RecomputeAllColors"))
end

local function redrawPage()
    if ReaderUI.instance and ReaderUI.instance.paging then
        UIManager:broadcastEvent(Event:new("RedrawCurrentPage"))
    end
end

-- Hook into night mode state changes and refresh page
local original_UIManager_ToggleNightMode = UIManager.ToggleNightMode
function UIManager:ToggleNightMode(night_mode)
    original_UIManager_ToggleNightMode(self, night_mode)

    if common.has_document_open() then
        recomputeAllColors()

        local footer = ReaderUI.instance.view and ReaderUI.instance.view.footer
        if footer and footer.progress_bar then
            footer.progress_bar:_setColors(footer.settings.progress_style_thin)
            footer:refreshFooter(true)
        end

        refreshCSS()
        if FixedBackgroundColor.get() or FixedFontColor.get() or FixedLinkColor.get() then
            redrawPage()
        end
    end
end

-- Only refresh page on applying a book theme in the reader
local original_ReaderUI_onApplyTheme = ReaderUI.onApplyTheme
function ReaderUI:onApplyTheme()
    if original_ReaderUI_onApplyTheme then
        original_ReaderUI_onApplyTheme(self)
    end

    refreshCSS()
    if FixedBackgroundColor.get() then
        redrawPage()
    end
end

-- Refresh CSS when toggling color inversion in reflowable documents (invert images)
local original_ReaderTypeset_onToggleNightmodeImages = ReaderTypeset.onToggleNightmodeImages
function ReaderTypeset:onToggleNightmodeImages(toggle)
    original_ReaderTypeset_onToggleNightmodeImages(self, toggle)

    if Screen.night_mode then
        refreshCSS()
    end
end

return book_items
