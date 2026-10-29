local Blitbuffer = require("ffi/blitbuffer")
local ColorWheelWidget = require("widgets/colorwheelwidget")
local Dispatcher = require("dispatcher")
local FootnoteWidget = require("ui/widget/footnotewidget")
local ReaderStyleTweak = require("apps/reader/modules/readerstyletweak")
local ReaderUI = require("apps/reader/readerui")
local Screen = require("device").screen
local Setting = require("lib/setting")
local UIManager = require("ui/uimanager")
local common = require("lib/common")
local util = require("util")

local HexFontColor = Setting("book_font_color_hex", "#000000")
local InvertFontColor = Setting("book_font_color_inverted", true)
local AltNightFontColor = Setting("book_font_color_alt_night", false)
local NightHexFontColor = Setting("book_font_color_night_hex", "#FFFFFF")
local FixedFontColor = Setting("book_font_color_fixed", true)

-- Cache
local fg_cached = {
    alt_night_color = AltNightFontColor.get(),
    invert_in_night_mode = InvertFontColor.get(),
    set_fixed_color = FixedFontColor.get(),
    hex = HexFontColor.get(),
    night_hex = NightHexFontColor.get(),
    last_hex = nil,
    fgcolor = nil,
}

-- Calculate the current hex value based on night mode and current settings
local function calculateHex(is_doc_css, doc)
    local hex = (Screen.night_mode and fg_cached.alt_night_color) and fg_cached.night_hex or fg_cached.hex
    if Screen.night_mode then
        if fg_cached.alt_night_color or not fg_cached.invert_in_night_mode then
            hex = common.invertColor(hex)
        end
        -- Invert hex again if the reflowable document is inverting it
        if is_doc_css and common.isColorInversionActive(doc) and not common.isGrayscale(hex) then
            hex = common.invertColor(hex)
        end
    end
    return hex
end

-- Recompute and cache the final fgcolor based on current settings
-- Applies night mode inversion if enabled, and updates fg_cached.fgcolor only if it has changed
local function recomputeFGColor()
    local hex = calculateHex()
    if hex ~= fg_cached.last_hex then
        fg_cached.fgcolor = Blitbuffer.colorFromString(hex)
        fg_cached.last_hex = hex
    end
end

-- Compute and cache the initial fgcolor based on current settings
recomputeFGColor()

local function getFontColor()
    if Screen.night_mode and fg_cached.alt_night_color then
        return NightHexFontColor.get()
    else
        return HexFontColor.get()
    end
end

local function setFontColor(hex)
    if Screen.night_mode and fg_cached.alt_night_color then
        NightHexFontColor.set(hex)
        fg_cached.night_hex = hex
    else
        HexFontColor.set(hex)
        fg_cached.hex = hex
    end

    recomputeFGColor()
end

-- Menus
local _ = require("gettext")
local T = require("ffi/util").template

local function pick_color_callback()
    return function(touchmenu_instance)
        local h, s, v = common.hexToHSV(getFontColor())
        local wheel
        local should_invert_wheel = AltNightFontColor.get() or not InvertFontColor.get()
        wheel = ColorWheelWidget:new({
            title_text = _("选择文字颜色"),
            hue = h,
            saturation = s,
            value = v,
            invert_in_night_mode = should_invert_wheel,
            callback = function(hex)
                setFontColor(hex)
                common.refreshPage()

                if touchmenu_instance then
                    touchmenu_instance:updateItems()
                end
                UIManager:setDirty(nil, "ui")
            end,
            cancel_callback = function()
                UIManager:setDirty(nil, "ui")
            end,
        })
        UIManager:show(wheel)
    end
end

local function font_color_menu()
    return {
        text_func = function()
            return T(_("文字颜色：%1"), getFontColor())
        end,
        sub_item_table = {
            {
                text_func = function()
                    return T(_("文字颜色：%1"), getFontColor())
                end,
                keep_menu_open = true,
                callback = pick_color_callback(),
            },
            {
                text = _("夜间模式使用独立颜色"),
                checked_func = AltNightFontColor.get,
                callback = function()
                    AltNightFontColor.toggle()
                    fg_cached.alt_night_color = AltNightFontColor.get()

                    if Screen.night_mode then
                        recomputeFGColor()

                        common.refreshPage()
                    end
                end,
            },
            {
                text = _("夜间模式反转颜色"),
                enabled_func = function() return not AltNightFontColor.get() end,
                checked_func = InvertFontColor.get,
                callback = function()
                    InvertFontColor.toggle()
                    fg_cached.invert_in_night_mode = InvertFontColor.get()
                    recomputeFGColor()

                    if Screen.night_mode then
                        common.refreshPage()
                    end
                end,
                separator = true,
            },
            {
                text = _("应用到阅读页面（PDF、DjVu、CBZ…）"),
                checked_func = FixedFontColor.get,
                callback = function()
                    FixedFontColor.toggle()
                    fg_cached.set_fixed_color = FixedFontColor.get()
                    common.refreshPage()
                end,
            },
        },
    }
end

-- Add font color to reader style tweak CSS if enabled
local original_ReaderStyleTweak_getCssText = ReaderStyleTweak.getCssText
function ReaderStyleTweak:getCssText()
    local original_css = original_ReaderStyleTweak_getCssText(self) or ""
    local css_hex = calculateHex(true, self.ui.document)

    local fg_css = [[
        body {
            color: ]] .. css_hex .. [[ !important;
        }
    ]]
    return util.trim(fg_css .. original_css)
end

-- Add font color to footnote popup CSS
local original_FootnoteWidget_init = FootnoteWidget.init
function FootnoteWidget:init()
    original_FootnoteWidget_init(self)

    local htmlwidget = self.htmlwidget
    local original_css = htmlwidget.css

    local fg_css = [[
        body {
            color: ]] .. calculateHex() .. [[ !important;
        }
    ]]
    htmlwidget.css = util.trim(fg_css .. original_css)
    htmlwidget.htmlbox_widget:setContent(htmlwidget.html_body, htmlwidget.css, htmlwidget.default_font_size,
        htmlwidget.is_xhtml, nil, htmlwidget.html_resource_directory)

    -- Use book foreground color for top border
    local vgroup = self.container[1]
    local single_page_height = self.htmlwidget:getSinglePageHeight()
    if single_page_height then
        vgroup = vgroup[1]
    end
    local linewidget = vgroup[1]
    linewidget.background = fg_cached.fgcolor
end

-- Recompute colors upon event call
local original_ReaderUI_onRecomputeAllColors = ReaderUI.onRecomputeAllColors
function ReaderUI:onRecomputeAllColors()
    if original_ReaderUI_onRecomputeAllColors then
        original_ReaderUI_onRecomputeAllColors(self)
    end

    recomputeFGColor()
end

-- Event handler for when a theme is applied
local original_ReaderUI_onApplyTheme = ReaderUI.onApplyTheme
function ReaderUI:onApplyTheme()
    if original_ReaderUI_onApplyTheme then
        original_ReaderUI_onApplyTheme(self)
    end

    fg_cached.hex = HexFontColor.get()
    fg_cached.night_hex = NightHexFontColor.get()
    fg_cached.alt_night_color = AltNightFontColor.get()
    recomputeFGColor()
end

-- Register toggling/setting application of font color to fixed document pages as dispatcher actions
local function ToggleBookFontColorFixed()
    FixedFontColor.toggle()
    fg_cached.set_fixed_color = FixedFontColor.get()
    common.refreshPage()
end

local function SetBookFontColorFixed(apply_on)
    FixedFontColor.set(apply_on)
    fg_cached.set_fixed_color = apply_on
    common.refreshPage()
end

ReaderUI.onToggleBookFontColorFixed = ToggleBookFontColorFixed
ReaderUI.onSetBookFontColorFixed = SetBookFontColorFixed

Dispatcher:registerAction("toggle_book_font_color_fixed", {
    category = "none",
    event = "ToggleBookFontColorFixed",
    title = _("切换是否将文字颜色应用到阅读页面（PDF、DjVu、CBZ…）"),
    general = true,
})

Dispatcher:registerAction("set_book_font_color_fixed", {
    category = "string",
    event = "SetBookFontColorFixed",
    title = _("设置是否将文字颜色应用到阅读页面（PDF、DjVu、CBZ…）"),
    args = { true, false },
    toggle = { _("开"), _("关") },
    general = true,
})

return {
    menu = font_color_menu,
    fgcolor = function() return fg_cached.fgcolor end,
    hex = function() return fg_cached.hex end,
    night_hex = function() return fg_cached.night_hex end,
    set_fixed_color = function() return fg_cached.set_fixed_color end
}
