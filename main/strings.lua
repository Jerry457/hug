GLOBAL.setfenv(1, GLOBAL)

local loc = require("languages/loc")

local language = loc.GetLanguage and loc.GetLanguage()
local code = loc.GetLocaleCode(language)

-- ModifyTranslatedStrings("STRINGS.NAMES.GHOSTLYELIXIR_REVIVE", "string")
function ModifyTranslatedStrings(path, str)
    local parts = {}

    for part in string.gmatch(path, "([^.]+)") do
        table.insert(parts, part)
    end

    local base = _G
    for i, part in ipairs(parts) do
        if i == # parts then
            base[part:upper()] = str
        else
            base = base[part:upper()]
        end
    end

    LanguageTranslator.languages[code][path] = str

    return str
end

if language == LANGUAGE.CHINESE_S or language == LANGUAGE.CHINESE_S_RAIL then
    require("localization/hug_strings_zh")
else
    require("localization/hug_strings_en")
end
