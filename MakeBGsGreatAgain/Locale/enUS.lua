-- enUS.lua — Textes anglais de l'addon MBGA
-- Crée MBGA_LOCALE_EN (table EN distincte, ne surcharge PAS MBGA_L au chargement)
-- MBGA_L est switché vers cette table via MBGA_SwitchLocale("EN") au runtime

MBGA_LOCALE_EN = {}
local L = MBGA_LOCALE_EN

-- Interface principale (commun)
L["TITLE"]              = "Make BG's Great Again"
L["FACTION_HORDE"]      = "Horde"
L["FACTION_ALLIANCE"]   = "Alliance"
L["LANG_FR"]            = "FR"
L["LANG_EN"]            = "EN"
L["BTN_BACK"]           = "← Back"
L["BTN_CLOSE"]          = "Close"

-- Sections de la fiche stratégie
L["SECTION_WIN"]        = "🎯 WIN CONDITION"
L["SECTION_RULE"]       = "⚠️ CRITICAL RULE"
L["SECTION_ROLES"]      = "ROLES"
L["SECTION_PLAN_A"]     = "📋 PLAN A"
L["SECTION_PLAN_B"]     = "🔄 PLAN B (if things go south)"

-- Catégories
L["CAT_NORMAL"]         = "BATTLEGROUNDS (10v10 / 15v15)"
L["CAT_EPIC"]           = "EPIC BATTLEGROUNDS (40v40)"

-- Noms des BGs (identiques EN et FR)
L["BG_WSG"]             = "Warsong Gulch"
L["BG_TP"]              = "Twin Peaks"
L["BG_AB"]              = "Arathi Basin"
L["BG_EOTS"]            = "Eye of the Storm"
L["BG_BFG"]             = "Battle for Gilneas"
L["BG_SSM"]             = "Silvershard Mines"
L["BG_TK"]              = "Temple of Kotmogu"
L["BG_DWG"]             = "Deepwind Gorge"
L["BG_SS"]              = "Seething Shore"
L["BG_DR"]              = "Deephaul Ravine"
L["BG_AV"]              = "Alterac Valley"
L["BG_IOC"]             = "Isle of Conquest"
L["BG_ASHRAN"]          = "Ashran"
L["BG_WG"]              = "Wintergrasp"
L["BG_SR"]              = "Slayer's Rise"
