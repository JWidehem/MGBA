-- frFR.lua — Textes français de l'addon MBGA
-- Crée MBGA_LOCALE_FR (source FR immuable)
-- MBGA_L est une table séparée, peuplée via MBGA_SwitchLocale("FR") à l'init

MBGA_LOCALE_FR = {}
MBGA_L = {}  -- table active — NE PAS aliaser sur MBGA_LOCALE_FR (SwitchLocale EN la corromprait)
local L = MBGA_LOCALE_FR

-- Interface principale
L["TITLE"]              = "Make BG's Great Again"
L["FACTION_HORDE"]      = "Horde"
L["FACTION_ALLIANCE"]   = "Alliance"
L["LANG_FR"]            = "FR"
L["LANG_EN"]            = "EN"
L["BTN_BACK"]           = "← Retour"
L["BTN_CLOSE"]          = "Fermer"

-- Sections de la fiche stratégie
L["SECTION_WIN"]        = "🎯 WIN CONDITION"
L["SECTION_RULE"]       = "⚠️ RÈGLE CRITIQUE"
L["SECTION_ROLES"]      = "RÔLES"
L["SECTION_PLAN_A"]     = "📋 PLAN A"
L["SECTION_PLAN_B"]     = "🔄 PLAN B (si ça part mal)"

-- Catégories de BGs
L["CAT_NORMAL"]         = "CHAMPS DE BATAILLE (10v10 / 15v15)"
L["CAT_EPIC"]           = "CHAMPS DE BATAILLE ÉPIQUES (40v40)"

-- Noms des BGs en français (noms officiels du client WoW FR)
L["BG_WSG"]             = "Goulet des Chanteguerres"
L["BG_TP"]              = "Doubles Cimes"
L["BG_AB"]              = "Bassin d'Arathi"
L["BG_EOTS"]            = "Oeil de la Tempete"
L["BG_BFG"]             = "La Bataille pour Gilneas"
L["BG_SSM"]             = "Mines d'Argentvif"
L["BG_TK"]              = "Temple de Kotmogu"
L["BG_DWG"]             = "Gorge du Vent Profond"
L["BG_SS"]              = "Rivage Ardent"
L["BG_DR"]              = "Ravin du Grand-Convoi"
L["BG_AV"]              = "Vallee d'Alterac"
L["BG_IOC"]             = "Ile de la Conquete"
L["BG_ASHRAN"]          = "Ashran"
L["BG_WG"]              = "Joug-d'hiver"
L["BG_SR"]              = "L'Essor du Massacreur"
