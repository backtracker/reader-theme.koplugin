local theme_list = {}

-- Default KOReader themes
theme_list.DEFAULT_DAY_THEME = { key = "default_day", label = "默认日间", bg = "#FFFFFF", fg = "#000000", accent = nil, link = nil, night = false }
theme_list.DEFAULT_NIGHT_THEME = { key = "default_night", label = "默认夜间", bg = "#000000", fg = "#FFFFFF", accent = nil, link = nil, night = true }

-- Default themes list
theme_list.DEFAULT_DAY_THEMES = {
    theme_list.DEFAULT_DAY_THEME,
    -- Neutral
    { key = "paper",            label = "纸张",            bg = "#F2F2F2", fg = "#1A1A1A", night = false },
    { key = "book_white",       label = "书白",            bg = "#F9F6F0", fg = "#1C1C1C", night = false },
    { key = "light_gray",       label = "浅灰",            bg = "#EDEDED", fg = "#4F4F4F", night = false },
    { key = "warm_stone",       label = "暖石",            bg = "#D7D5D3", fg = "#000000", night = false },
    -- Warm/Sepia
    { key = "cream",            label = "奶油",            bg = "#F3EFD8", fg = "#111111", night = false },
    { key = "parchment",        label = "羊皮纸",          bg = "#EBE0C9", fg = "#2C1A0E", night = false },
    { key = "soft_parchment",   label = "柔和羊皮纸",      bg = "#EBE0C9", fg = "#645031", night = false },
    { key = "warm_parchment",   label = "暖羊皮纸",        bg = "#F0E2C8", fg = "#3D2010", night = false },
    { key = "sepia",            label = "棕褐",            bg = "#F5E6C8", fg = "#2C1A0E", night = false },
    { key = "light_sepia",      label = "浅棕褐",          bg = "#F7ECD8", fg = "#2C1A0E", night = false },
    { key = "warm_sepia",       label = "暖棕褐",          bg = "#E3D1B3", fg = "#422A14", night = false },
    { key = "aged_paper",       label = "旧纸",            bg = "#F5EDD6", fg = "#2C1A0E", night = false },
    { key = "manila",           label = "马尼拉纸",        bg = "#F2E8C8", fg = "#1A0E00", night = false },
    { key = "sand",             label = "沙色",            bg = "#EDE0C4", fg = "#2E1F0A", night = false },
    { key = "old_book",         label = "旧书",            bg = "#EDD9B0", fg = "#2E1800", night = false },
    { key = "tan",              label = "棕黄",            bg = "#E8D5B0", fg = "#2A1500", night = false },
    { key = "butterscotch",     label = "奶糖",            bg = "#F5DFA0", fg = "#3D2000", night = false },
    { key = "caramel",          label = "焦糖",            bg = "#E8C888", fg = "#2A1000", night = false },
    { key = "almonds",          label = "杏仁",            bg = "#F1DAC4", fg = "#3A3080", night = false },
    -- Warm tinted
    { key = "dyslexia",         label = "阅读友好",        bg = "#F8F0D8", fg = "#3D2B1F", night = false },
    { key = "solarized_light",  label = "日光",            bg = "#FDF6E3", fg = "#657B83", night = false },
    -- Green
    { key = "golden_green",     label = "金绿",            bg = "#E1FFE3", fg = "#8A9229", night = false },
    { key = "green_tea",        label = "绿茶",            bg = "#D4E8D0", fg = "#1A3320", night = false },
    { key = "sage",             label = "鼠尾草绿",        bg = "#EAF0E8", fg = "#1A2E1A", night = false },
    { key = "mint",             label = "薄荷",            bg = "#E8F5F0", fg = "#0A2E1E", night = false },
    { key = "pale_moss",        label = "浅苔",            bg = "#EAF2E0", fg = "#1A2E0A", night = false },
    { key = "fern",             label = "蕨绿",            bg = "#DFF0E0", fg = "#0F2A14", night = false },
    { key = "soft_green",       label = "柔绿",            bg = "#E4EEE0", fg = "#1A3020", night = false },
    -- Blue
    { key = "arctic",           label = "极地蓝",          bg = "#E8F0F8", fg = "#0D1B2A", night = false },
    { key = "cool_mist",        label = "冷雾",            bg = "#EBEFF5", fg = "#052F75", night = false },
    { key = "sky",              label = "天空蓝",          bg = "#E8F4FC", fg = "#0A2040", night = false },
    { key = "ice_blue",         label = "冰蓝",            bg = "#EAF2FA", fg = "#0D2840", night = false },
    { key = "pale_blue",        label = "浅蓝",            bg = "#EEF4FF", fg = "#0A1E3C", night = false },
    { key = "powder_blue",      label = "粉蓝",            bg = "#E8F0F8", fg = "#1A3050", night = false },
    { key = "blue_fields",      label = "蓝田",            bg = "#CBFCFF", fg = "#373598", night = false },
    -- Purple
    { key = "lavender_mist",    label = "薰衣草雾",        bg = "#F0EEF8", fg = "#2A2040", night = false },
    -- Pink
    { key = "rose_tint",        label = "玫瑰灰",          bg = "#FAF0F0", fg = "#2A1A1A", night = false },
    { key = "pastel_pink",      label = "柔粉",            bg = "#FFDDE2", fg = "#DE369D", night = false },
    -- Programming themes
    { key = "github_light",     label = "GitHub 亮色",     bg = "#FFFFFF", fg = "#24292F", night = false },
    { key = "one_light",        label = "One 亮色",        bg = "#FAFAFA", fg = "#383A42", night = false },
    { key = "tomorrow",         label = "明日",            bg = "#FFFFFF", fg = "#4D4D4C", night = false },
    { key = "gruvbox_light",    label = "Gruvbox 亮色",    bg = "#FBF1C7", fg = "#3C3836", night = false },
    { key = "catppuccin_latte", label = "拿铁",            bg = "#EFF1F5", fg = "#4C4F69", night = false },
    { key = "rose_pine_dawn",   label = "曙光",            bg = "#FAF4ED", fg = "#575279", night = false },
}

theme_list.DEFAULT_NIGHT_THEMES = {
    theme_list.DEFAULT_NIGHT_THEME,
    -- Dark neutrals
    { key = "ink",              label = "墨黑",            bg = "#050505", fg = "#E0E0E0", night = true },
    { key = "mono_dark",        label = "单色暗",          bg = "#1A1A1A", fg = "#F5F5F5", night = true },
    { key = "twilight",         label = "暮色",            bg = "#282A2C", fg = "#FFFFFF", night = true },
    { key = "dim_night",        label = "微光夜",          bg = "#121212", fg = "#B0B0B0", night = true },
    { key = "charcoal",         label = "炭黑",            bg = "#1E1E1E", fg = "#D4D4D4", night = true },
    -- Warm/Sepia
    { key = "amber_night",      label = "琥珀夜",          bg = "#14100A", fg = "#FAD08A", night = true },
    { key = "candlelight",      label = "烛光",            bg = "#1A1000", fg = "#E8C87A", night = true },
    { key = "deep_sepia",       label = "深棕褐",          bg = "#1A1008", fg = "#C8A87A", night = true },
    { key = "dark_sepia",       label = "暗棕褐",          bg = "#1A0E00", fg = "#C8A070", night = true },
    { key = "coffee",           label = "咖啡",            bg = "#140C00", fg = "#C8A878", night = true },
    { key = "dark_parchment",   label = "暗羊皮纸",        bg = "#1E1408", fg = "#D4B888", night = true },
    { key = "tobacco",          label = "烟草",            bg = "#180E04", fg = "#C8A060", night = true },
    { key = "burnt_wood",       label = "焦木",            bg = "#120800", fg = "#B87840", night = true },
    { key = "dark_caramel",     label = "焦糖暗",          bg = "#1A0C00", fg = "#D4A050", night = true },
    { key = "warm_dark",        label = "暖暗",            bg = "#1A1410", fg = "#D4C4A8", night = true },
    { key = "dim_amber",        label = "幽琥珀",          bg = "#0F0A00", fg = "#D4A84B", night = true },
    -- Green
    { key = "forest_night",     label = "森林夜",          bg = "#0D1A0D", fg = "#A8C8A0", night = true },
    { key = "dark_moss",        label = "暗苔",            bg = "#0A1A0A", fg = "#90C090", night = true },
    { key = "pine",             label = "松林",            bg = "#0A1810", fg = "#88C0A0", night = true },
    { key = "deep_forest",      label = "深林",            bg = "#081408", fg = "#80B880", night = true },
    -- Blue/Teal
    { key = "slate",            label = "石板",            bg = "#2C3E50", fg = "#DCDCDC", night = true },
    { key = "midnight_blue",    label = "午夜蓝",          bg = "#0D1117", fg = "#A0B4C8", night = true },
    { key = "deep_ocean",       label = "深海",            bg = "#0A1628", fg = "#8BAFD4", night = true },
    { key = "dark_sky",         label = "暗空",            bg = "#0A1428", fg = "#7AAAD4", night = true },
    { key = "night_blue",       label = "夜蓝",            bg = "#0D1520", fg = "#90B8D8", night = true },
    { key = "moonlight",        label = "月光",            bg = "#12121E", fg = "#C8C8E0", night = true },
    { key = "french_blue",      label = "法国蓝",          bg = "#003F91", fg = "#E5F4E3", night = true },
    -- Purple
    { key = "grape",            label = "葡萄紫",          bg = "#474973", fg = "#F9F5E3", night = true },
    { key = "velvet",           label = "天鹅绒",          bg = "#532653", fg = "#F9D592", night = true },
    { key = "wisteria_night",   label = "紫藤夜",          bg = "#150D1F", fg = "#E5D1F5", night = true },
    -- Programming themes
    { key = "dracula",          label = "德古拉",          bg = "#282A36", fg = "#F8F8F2", night = true },
    { key = "nord",             label = "北境",            bg = "#2E3440", fg = "#D8DEE9", night = true },
    { key = "gruvbox_dark",     label = "Gruvbox 暗色",    bg = "#282828", fg = "#EBDBB2", night = true },
    { key = "one_dark",         label = "One 暗色",        bg = "#282C34", fg = "#ABB2BF", night = true },
    { key = "tokyo_night",      label = "东京夜",          bg = "#1A1B26", fg = "#C0CAF5", night = true },
    { key = "catppuccin_mocha", label = "摩卡",            bg = "#1E1E2E", fg = "#CDD6F4", night = true },
    { key = "monokai",          label = "Monokai",         bg = "#272822", fg = "#F8F8F2", night = true },
    { key = "material_dark",    label = "材质暗色",        bg = "#263238", fg = "#EEFFFF", night = true },
    { key = "rose_pine",        label = "玫瑰松",          bg = "#191724", fg = "#E0DEF4", night = true },
}

return theme_list
