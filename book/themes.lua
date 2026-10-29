local Blitbuffer = require("ffi/blitbuffer")
local ButtonDialog = require("ui/widget/buttondialog")
local ColorWheelWidget = require("widgets/colorwheelwidget")
local ConfirmBox = require("ui/widget/confirmbox")
local Dispatcher = require("dispatcher")
local Event = require("ui/event")
local InfoMessage = require("ui/widget/infomessage")
local InputDialog = require("ui/widget/inputdialog")
local MultiConfirmBox = require("ui/widget/multiconfirmbox")
local ReaderUI = require("apps/reader/readerui")
local Screen = require("device").screen
local Setting = require("lib/setting")
local Settings = require("lib/settings")
local UIManager = require("ui/uimanager")
local common = require("lib/common")
local theme_list = require("lib/theme_list")
local _ = require("gettext")
local T = require("ffi/util").template

-- Book colors
local BookHexBackgroundColor = Setting("book_background_color_hex", "#FFFFFF")
local BookInvertBackgroundColor = Setting("book_background_color_inverted", true)
local BookAltNightBackgroundColor = Setting("book_background_color_alt_night", false)
local BookNightHexBackgroundColor = Setting("book_background_color_night_hex", "#000000")
local BookHexFontColor = Setting("book_font_color_hex", "#000000")
local BookAltNightFontColor = Setting("book_font_color_alt_night", false)
local BookNightHexFontColor = Setting("book_font_color_night_hex", "#FFFFFF")
local BookHexLinkColor = Setting("book_link_color_hex", nil)
local BookAltNightLinkColor = Setting("book_link_color_alt_night", false)
local BookNightHexLinkColor = Setting("book_link_color_night_hex", nil)

-- 沿用旧键名，保留用户已有的主题列表
local DayThemes = Setting("ui_themes_day", theme_list.DEFAULT_DAY_THEMES)
local NightThemes = Setting("ui_themes_night", theme_list.DEFAULT_NIGHT_THEMES)
local CurrentBookDayTheme = Setting("book_themes_current_day", theme_list.DEFAULT_DAY_THEME)
local CurrentBookNightTheme = Setting("book_themes_current_night", theme_list.DEFAULT_NIGHT_THEME)

local cached = {
    dayThemes = DayThemes.get(),
    nightThemes = NightThemes.get(),
}

local function setBackgroundColor(hex, night)
    if not night then
        BookHexBackgroundColor.set(hex)
    else
        BookAltNightBackgroundColor.set(true)
        BookNightHexBackgroundColor.set(hex)
    end
end

local function setForegroundColor(hex, night)
    if not night then
        BookHexFontColor.set(hex)
    else
        BookAltNightFontColor.set(true)
        BookNightHexFontColor.set(hex)
    end
end

local function setLinkColor(hex, night)
    if not night then
        BookHexLinkColor.set(hex)
    else
        BookAltNightLinkColor.set(true)
        BookNightHexLinkColor.set(hex)
    end
end

local ColorType = { BACKGROUND = "background", FOREGROUND = "foreground", LINK = "link" }
local ColorLabel = {
    background = _("背景"),
    foreground = _("文字"),
    link = _("链接"),
}

local function pick_color_menu(touchmenu_instance, color_type, original_hex, callback, skippable)
    if not original_hex then
        if color_type == ColorType.BACKGROUND then
            original_hex = theme_list.DEFAULT_DAY_THEME.bg
        elseif color_type == ColorType.FOREGROUND then
            original_hex = theme_list.DEFAULT_DAY_THEME.fg
        elseif color_type == ColorType.LINK then
            original_hex = "#0000EE"
        end
    end

    local h, s, v = common.hexToHSV(original_hex)
    local should_invert_wheel = BookAltNightBackgroundColor.get() or not BookInvertBackgroundColor.get()
    return ColorWheelWidget:new({
        title_text = T(_("选择%1颜色"), ColorLabel[color_type] or color_type),
        cancel_text = skippable and _("跳过") or _("取消"),
        hue = h,
        saturation = s,
        value = v,
        invert_in_night_mode = should_invert_wheel,
        callback = function(hex)
            callback(hex)

            if touchmenu_instance then
                touchmenu_instance:updateItems()
            end
            UIManager:setDirty(nil, "ui")
        end,
        close_callback = function()
            UIManager:setDirty(nil, "ui")
        end,
        cancel_callback = function()
            if skippable then
                callback(nil)
            end
        end
    })
end

local function add_theme(name, bg_hex, fg_hex, link_hex, night)
    local key = string.lower(name:gsub(" ", "_"))
    local theme = {
        key = key,
        label = name,
        bg = bg_hex,
        fg = fg_hex,
        link = link_hex,
        night = night,
    }

    if not night then
        table.insert(cached.dayThemes, theme)
        DayThemes.set(cached.dayThemes)
    else
        table.insert(cached.nightThemes, theme)
        NightThemes.set(cached.nightThemes)
    end
    Settings:flushSettings()

    return theme
end

local function replace_theme(theme, val)
    if not theme.night then
        for i, v in ipairs(cached.dayThemes) do
            if v.key == theme.key then
                cached.dayThemes[i] = val
                break
            end
        end
        DayThemes.set(cached.dayThemes)
    else
        for i, v in ipairs(cached.nightThemes) do
            if v.key == theme.key then
                cached.nightThemes[i] = val
                break
            end
        end
        NightThemes.set(cached.nightThemes)
    end
    Settings:flushSettings()
end

local function remove_theme(theme)
    if not theme.night then
        for i, v in ipairs(cached.dayThemes) do
            if v.key == theme.key then
                table.remove(cached.dayThemes, i)
                break
            end
        end
        DayThemes.set(cached.dayThemes)
    else
        for i, v in ipairs(cached.nightThemes) do
            if v.key == theme.key then
                table.remove(cached.nightThemes, i)
                break
            end
        end
        NightThemes.set(cached.nightThemes)
    end
    Settings:flushSettings()
end

local function setTheme(theme, night)
    setBackgroundColor(theme.bg, night)
    setForegroundColor(theme.fg, night)
    setLinkColor(theme.link, night)
end

local edit_menu
local ask_to_apply

local function themeButtonText(theme)
    local text = T(_("%1  %2  %3"), theme.night and "⏾" or "☀", theme.label, theme.fg)
    if theme.link then
        text = text .. "  " .. theme.link
    end
    return text
end

-- 夜间模式下整个画面会被反色，预览色需要预先反色才能显示主题本色
local function previewColor(hex)
    local color = Blitbuffer.colorFromString(hex)
    return Screen.night_mode and color:invert() or color
end

local function colorizeThemeButtons(dialog, themes)
    local buttontable = dialog and dialog.buttontable
    if not buttontable then return end
    for i, theme in ipairs(themes) do
        local button = buttontable.button_by_id[i]
        if button and button.label_widget then
            button.label_widget.fgcolor = previewColor(theme.fg)
        end
    end
end

local function showNoThemesMessage()
    UIManager:show(InfoMessage:new({
        text = _("没有主题。请添加新主题或重置主题列表。"),
        timeout = 5,
    }))
end

local function getThemeButtons(touchmenu_instance, dialog_ref)
    local buttons = {}
    local themes = {}
    for _, v in ipairs(cached.dayThemes) do table.insert(themes, v) end
    for _, v in ipairs(cached.nightThemes) do table.insert(themes, v) end

    for i, theme in ipairs(themes) do
        buttons[i] = { {
            text = themeButtonText(theme),
            menu_style = true,
            background = previewColor(theme.bg),
            id = i,
            callback = function()
                ask_to_apply(theme)
                UIManager:close(dialog_ref.dialog)
            end,
            hold_callback = function()
                UIManager:show(edit_menu(touchmenu_instance, theme, dialog_ref))
            end
        } }
    end
    return buttons, themes
end

edit_menu = function(touchmenu_instance, theme, updialog_ref)
    local function refreshThemeButtons()
        local scrolled_offset = 0
        if updialog_ref.dialog then
            scrolled_offset = updialog_ref.dialog:getScrolledOffset()
            UIManager:close(updialog_ref.dialog)
        end
        local new_ref = {}
        local buttons, themes = getThemeButtons(touchmenu_instance, new_ref)
        if #buttons == 0 then
            showNoThemesMessage()
            return
        end

        local new_updialog = ButtonDialog:new {
            buttons = buttons,
            width_factor = 0.6,
            colorful = true,
            dithered = true,
            rows_per_page = 10,
        }
        colorizeThemeButtons(new_updialog, themes)
        new_updialog:setScrolledOffset(scrolled_offset)
        new_ref.dialog = new_updialog
        updialog_ref.dialog = new_updialog
        UIManager:show(new_updialog)
    end

    local edit_buttons = {
        { {
            text = _("重命名"),
            callback = function()
                local input_dialog
                input_dialog = InputDialog:new({
                    title = _("输入主题的新名称："),
                    input = theme.label,
                    buttons = {
                        {
                            {
                                text = _("取消"),
                                callback = function()
                                    UIManager:close(input_dialog)
                                end,
                            },
                            {
                                text = _("保存"),
                                callback = function()
                                    local text = input_dialog:getInputText()

                                    if text ~= "" then
                                        theme.label = text
                                        replace_theme(theme, theme)
                                        refreshThemeButtons()

                                        UIManager:close(input_dialog)
                                        UIManager:close(dialog)
                                    end
                                end,
                            }
                        }
                    }
                })
                UIManager:show(input_dialog)
                input_dialog:onShowKeyboard()
            end,
        } },
        { {
            text = _("修改背景色"),
            callback = function()
                UIManager:show(pick_color_menu(touchmenu_instance, ColorType.BACKGROUND, theme.bg, function(bg_hex)
                    theme.bg = bg_hex
                    replace_theme(theme, theme)

                    UIManager:close(dialog)
                    refreshThemeButtons()
                end))
            end,
        } },
        { {
            text = _("修改文字色"),
            callback = function()
                UIManager:show(pick_color_menu(touchmenu_instance, ColorType.FOREGROUND, theme.fg, function(fg_hex)
                    theme.fg = fg_hex
                    replace_theme(theme, theme)

                    UIManager:close(dialog)
                    refreshThemeButtons()
                end))
            end,
        } },
        { {
            text = _("修改链接色"),
            callback = function()
                UIManager:show(pick_color_menu(touchmenu_instance, ColorType.LINK, theme.link, function(link_hex)
                    theme.link = link_hex
                    replace_theme(theme, theme)

                    UIManager:close(dialog)
                    refreshThemeButtons()
                end))
            end,
        } },
        { {
            text = _("删除"),
            callback = function()
                remove_theme(theme)

                UIManager:close(dialog)
                refreshThemeButtons()
            end,
        } },
    }

    if theme.link then
        table.insert(edit_buttons, 5, { {
            text = _("重置链接色"),
            callback = function()
                theme.link = nil
                replace_theme(theme, theme)

                UIManager:close(dialog)
                refreshThemeButtons()
            end,
        } })
    end

    local dialog = ButtonDialog:new {
        buttons = edit_buttons,
        width_factor = 0.5,
        colorful = true,
        dithered = true,
    }
    return dialog
end

local function apply_theme(theme)
    if theme.night then
        CurrentBookNightTheme.set(theme)
    else
        CurrentBookDayTheme.set(theme)
    end

    setTheme(theme, theme.night)
    UIManager:broadcastEvent(Event:new("ApplyTheme"))
end

ask_to_apply = function(theme, reapply)
    UIManager:show(ConfirmBox:new({
        text = reapply and _("重新应用此主题？") or _("现在应用此主题？"),
        ok_text = _("应用"),
        ok_callback = function()
            apply_theme(theme)
        end,
    }))
end

local function select_mode(name, bg_hex, fg_hex, link_hex)
    UIManager:show(MultiConfirmBox:new({
        text = _("该主题用于："),
        choice1_text = _("日间模式"),
        choice1_callback = function()
            local theme = add_theme(name, bg_hex, fg_hex, link_hex, false)
            ask_to_apply(theme)
        end,
        choice2_text = _("夜间模式"),
        choice2_callback = function()
            local theme = add_theme(name, bg_hex, fg_hex, link_hex, true)
            ask_to_apply(theme)
        end,
    }))
end

local function themes_menu()
    return {
        text_func = function() return _("阅读主题") end,
        sub_item_table_func = function()
            return {
                {
                    text_func = function()
                        return T(_("当前日间主题：%1"), CurrentBookDayTheme.get().label)
                    end,
                    callback = function()
                        ask_to_apply(CurrentBookDayTheme.get(), true)
                    end,
                },
                {
                    text_func = function()
                        return T(_("当前夜间主题：%1"), CurrentBookNightTheme.get().label)
                    end,
                    callback = function()
                        ask_to_apply(CurrentBookNightTheme.get(), true)
                    end,
                    separator = true,
                },
                {
                    text = _("选择主题"),
                    callback = function(touchmenu_instance)
                        local dialog_ref = {}
                        local buttons, themes = getThemeButtons(touchmenu_instance, dialog_ref)
                        if #buttons == 0 then
                            showNoThemesMessage()
                            return
                        end

                        local dialog = ButtonDialog:new {
                            buttons = buttons,
                            width_factor = 0.6,
                            colorful = true,
                            dithered = true,
                            rows_per_page = 10,
                        }
                        colorizeThemeButtons(dialog, themes)
                        dialog_ref.dialog = dialog
                        UIManager:show(dialog)
                    end,
                },
                {
                    text = _("添加主题"),
                    callback = function(touchmenu_instance)
                        local input_dialog
                        input_dialog = InputDialog:new({
                            title = _("输入主题名称："),
                            buttons = {
                                {
                                    {
                                        text = _("取消"),
                                        callback = function()
                                            UIManager:close(input_dialog)
                                        end,
                                    },
                                    {
                                        text = _("下一步"),
                                        callback = function()
                                            local text = input_dialog:getInputText()

                                            if text ~= "" then
                                                UIManager:show(pick_color_menu(touchmenu_instance,
                                                    ColorType.BACKGROUND, nil,
                                                    function(bg_hex)
                                                        UIManager:show(pick_color_menu(touchmenu_instance,
                                                            ColorType.FOREGROUND, nil,
                                                            function(fg_hex)
                                                                UIManager:show(pick_color_menu(touchmenu_instance,
                                                                    ColorType.LINK, nil,
                                                                    function(link_hex)
                                                                        select_mode(text, bg_hex, fg_hex, link_hex)
                                                                    end, true))
                                                            end))
                                                    end))

                                                UIManager:close(input_dialog)
                                            end
                                        end,
                                    },
                                },
                            }
                        })
                        UIManager:show(input_dialog)
                        input_dialog:onShowKeyboard()
                    end,
                },
                {
                    text = _("重置主题"),
                    sub_item_table = {
                        {
                            text = _("恢复当前主题"),
                            keep_menu_open = true,
                            callback = function()
                                setTheme(CurrentBookDayTheme.get(), false)
                                setTheme(CurrentBookNightTheme.get(), true)
                                UIManager:broadcastEvent(Event:new("ApplyTheme"))
                            end,
                        },
                        {
                            text = _("恢复默认主题"),
                            keep_menu_open = true,
                            callback = function()
                                CurrentBookDayTheme.set(theme_list.DEFAULT_DAY_THEME)
                                CurrentBookNightTheme.set(theme_list.DEFAULT_NIGHT_THEME)

                                setTheme(theme_list.DEFAULT_DAY_THEME, false)
                                setTheme(theme_list.DEFAULT_NIGHT_THEME, true)
                                UIManager:broadcastEvent(Event:new("ApplyTheme"))
                            end,
                        },
                        {
                            text = _("重置主题列表"),
                            keep_menu_open = true,
                            callback = function()
                                DayThemes.set(theme_list.DEFAULT_DAY_THEMES)
                                cached.dayThemes = DayThemes.get()
                                NightThemes.set(theme_list.DEFAULT_NIGHT_THEMES)
                                cached.nightThemes = NightThemes.get()
                            end,
                        },
                    },
                },
            }
        end,
    }
end

local function getThemeActions(night)
    local action_nums, action_texts = {}, {}

    local themes = night and cached.nightThemes or cached.dayThemes

    for i, theme in ipairs(themes) do
        table.insert(action_nums, i)
        table.insert(action_texts, theme.label)
    end
    return action_nums, action_texts
end

local ApplicationMode = {
    DAY_BOOK = 1,
    NIGHT_BOOK = 2,
}

local theme_setters = {
    [ApplicationMode.DAY_BOOK] = CurrentBookDayTheme,
    [ApplicationMode.NIGHT_BOOK] = CurrentBookNightTheme,
}

local function SelectTheme(_, args)
    if not args or #args < 2 then return end
    local application_mode, action_num = args[1], args[2]

    local night = application_mode == ApplicationMode.NIGHT_BOOK
    local themes = night and cached.nightThemes or cached.dayThemes

    local theme = themes[action_num]
    if not theme then return end

    local setter = theme_setters[application_mode]
    if setter then
        setter.set(theme)
    end

    setTheme(theme, night)
    UIManager:broadcastEvent(Event:new("ApplyTheme"))
end

ReaderUI.onSelectTheme = SelectTheme

Dispatcher:registerAction("ui_themes_select_day_book", {
    category = "string",
    event = "SelectTheme",
    arg = ApplicationMode.DAY_BOOK,
    title = _("选择日间阅读主题"),
    args_func = function() return getThemeActions(false) end,
    general = true,
})

Dispatcher:registerAction("ui_themes_select_night_book", {
    category = "string",
    event = "SelectTheme",
    arg = ApplicationMode.NIGHT_BOOK,
    title = _("选择夜间阅读主题"),
    args_func = function() return getThemeActions(true) end,
    general = true,
})

return themes_menu
