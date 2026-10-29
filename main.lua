local Settings = require("lib/settings")
local WidgetContainer = require("ui/widget/container/widgetcontainer")
local _ = require("gettext")
local book_items = require("book/book")
local common = require("lib/common")

local BookAppearance = WidgetContainer:extend({
    name = "appearance",
    title = _("阅读外观"),
    is_doc_only = true,
})

function BookAppearance:init()
    self.ui.menu:registerToMainMenu(self)
end

function BookAppearance:onFlushSettings()
    Settings:flushSettings()
end

function BookAppearance:addToMainMenu(menu_items)
    local reader_menu_order = require("ui/elements/reader_menu_order")
    if not common.contains(reader_menu_order.setting, "appearance") then
        table.insert(reader_menu_order.setting, 6, "appearance")
    end

    menu_items.appearance = {
        sorting_hint = "setting",
        text = self.title,
        sub_item_table = book_items(),
    }
end

return BookAppearance
