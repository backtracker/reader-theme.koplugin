# reader-theme.koplugin

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](LICENSE)
[![Lua](https://img.shields.io/badge/Lua-%232C2D72.svg?logo=lua&logoColor=white)](#)

只作用于**阅读器（打开书籍之后）**的阅读外观插件，用于和**月读（Moon）**等界面主题插件配合使用：界面主题交给 Moon，本插件只负责阅读页正文与底栏进度条的外观，因此不会与 Moon 的界面主题互相覆盖。

## 功能

| 分类 | 可调整的内容 |
|---|---|
| **阅读主题** | 一键套用日间 / 夜间阅读主题，可添加、重命名、修改颜色、删除 |
| **颜色** | 阅读页背景色、文字色、链接色 |
| **高亮颜色** | 标注颜色的名称与色值，设置默认高亮色 |
| **进度条颜色** | 底部进度条的已读 / 未读颜色（粗、细两种样式） |
| **进度条圆角** | 进度条圆角半径与圆角填充 |
| **取色器** | 可视化 RGB 色轮取色 |
| **固定版式页面** | 背景色 / 文字色 / 链接色可应用到 PDF、DjVu、CBZ 等固定版式文档 |

## 安装

1. 下载最新的 `reader-theme.koplugin.zip`。
2. 解压得到 `reader-theme.koplugin` 文件夹。
3. 将文件夹放到设备的 `koreader/plugins` 目录下。
4. 重启 KOReader。

## 使用

在阅读界面中打开菜单，选择 **设置 → 阅读外观**。插件只在阅读器中注册菜单，文件管理器与桌面不会出现它的入口。

- **阅读主题**：选择任意主题即可立即应用；长按主题可重命名、修改背景色 / 文字色 / 链接色或删除。主题也可通过“手势 / 配置”里的调度动作切换。
- **背景颜色 / 文字颜色 / 链接颜色**：点击色值打开色轮取色。可分别设置夜间模式使用的独立颜色、是否在夜间模式反转颜色，以及是否把颜色应用到固定版式页面（PDF、DjVu、CBZ…）。
- **高亮颜色**：点击颜色直接改色，长按可重命名、设为默认或重置。
- **进度条颜色 / 圆角**：调整底部进度条已读、未读颜色和圆角。若 Moon 接管了底部栏，这两项菜单会自动隐藏。

## 与 Moon 共存

- 插件以 `is_doc_only` 方式加载，只在阅读器中工作，不修改文件管理器、桌面、对话框等界面。
- 检测到 Moon 正在阅读页使用壁纸（`wallpaper_reader` 已开启且配置了图片）时，本插件不会写入阅读页背景色，避免覆盖壁纸。
- 检测到 Moon 接管了阅读器底部栏时，自动隐藏本插件的进度条菜单。
- Moon 的配置文件只读不写；本插件自己的设置保存在 `koreader/settings/appearance.lua`。

## 配置说明

设置保存在 `koreader/settings/appearance.lua`。旧版本的 `book_*` 系列设置键与阅读主题列表（`ui_themes_day` / `ui_themes_night`）会继续沿用，升级后原有配色与自定义主题不会丢失。

## 致谢

- 功能源自 [appearance.koplugin](https://github.com/Euphoriyy/appearance.koplugin) 的阅读页部分。
- 主题功能参考 [2-color-theme.lua](https://github.com/artemartemenko/koreader-color-themes) by [@artemartemenko](https://github.com/artemartemenko)（GPL-3.0）。
- 取色器亮度滑杆参考 [ink-away.koplugin](https://github.com/EmirErtorer/ink-away.koplugin) by [@EmirErtorer](https://github.com/EmirErtorer)（MIT）。
- 打包脚本参考 [ComicReader](https://github.com/KORComic/comicreader.koplugin) by [@OGKevin](https://github.com/OGKevin)（AGPL-3.0）。

## 许可证

本项目基于 **GNU General Public License v3.0** 发布，详见 [LICENSE](./LICENSE)。
