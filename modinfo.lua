local function en_zh(en, zh)
    return (locale == "zh" or locale == "zhr" or locale == "zht" or locale == "ch" or locale == "chs") and zh or en
end

-- This information tells other players more about the mod
version = "2.0.0" -- mod版本 上传mod需要两次的版本不一样
name = en_zh("WarmHug", "暖心相拥")  ---mod名字
description = en_zh(
    "-This mod allows you to hug your friends. When you are close enough to another player, you can click on them to initiate a hug.\n-During the hug, both of your body temperatures will gradually converge to a middle value. No matter how harsh the weather is—whether it’s freezing cold or scorching hot—hugging can help both of you survive better.\n-All original Don't Starve characters have specific dialogue when hugging! I carefully studied each character's speaking style to ensure their lines match their personalities.",
    "-这个模组让你能够拥抱你的朋友。当你们之间的距离足够近时，你可以点击对方，发起拥抱的动作。\n-拥抱过程中，你和对方的体温会逐渐趋于一个中间值，无论天气多么严寒或酷暑，拥抱都能帮助你和朋友更好地生存。\n-所有原版饥荒角色检查正在拥抱的其他原版角色，都有对应的台词！我仔细研究了每个角色的说话风格，确保他们的对话符合个性！\n\n"
)  --mod描述
author = en_zh("Guto、jerry457","Guto、jerry457") --作者

-- This is the URL name of the mod's thread on the forum; the part after the ? and before the first & in the url
forumthread = ""

folder_name = folder_name or "workshop-"
if not folder_name:find("workshop-") then
    name = name .. "-dev"
end

-- This lets other players know if your mod is out of date, update it to match the current version in the game
api_version = 10

-- Compatible with Don't Starve Together
dst_compatible = true --兼容联机

-- Not compatible with Don't Starve
dont_starve_compatible = false --不兼容原版
reign_of_giants_compatible = false --不兼容巨人DLC

-- Character mods need this set to true
all_clients_require_mod = true
client_only_mod = false --所有人mod

priority = 9999

icon_atlas = "modicon.xml" --mod图标
icon = "modicon.tex"

-- The mod's tags displayed on the server list
server_filter_tags = {  --服务器标签
    "warmhug",
}

configuration_options = {} --mod设置
