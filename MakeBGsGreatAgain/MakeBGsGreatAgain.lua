-- MakeBGsGreatAgain.lua — Point d'entrée principal de l'addon
-- Initialise l'addon, gère les événements globaux et orchestre les modules UI

-- État global de l'addon
MBGA_State = {
    faction  = UnitFactionGroup("player") or "Horde",  -- "Horde" ou "Alliance"
    lang     = "FR",                                    -- "FR" ou "EN"
    currentBG = nil,                                    -- ID du BG actif (Phase 2)
}

-- ─── Switch de locale au runtime ─────────────────────────────────────────────
-- MBGA_L est la table active. MBGA_LOCALE_FR / MBGA_LOCALE_EN sont les sources.
-- Appelé depuis les boutons FR/EN dans l'UI.

function MBGA_SwitchLocale(lang)
    MBGA_State.lang = lang
    local source = (lang == "EN") and MBGA_LOCALE_EN or MBGA_LOCALE_FR
    for k, v in pairs(source) do
        MBGA_L[k] = v
    end
end

-- Frame principale pour les événements d'initialisation
local eventFrame = CreateFrame("Frame")

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "MakeBGsGreatAgain" then
            MBGA_OnAddonLoaded()
        end

    elseif event == "PLAYER_LOGIN" then
        MBGA_OnPlayerLogin()
    end
end)

-- Appelé au chargement de l'addon — initialisation des données
function MBGA_OnAddonLoaded()
    -- Met à jour la faction depuis le personnage réel
    MBGA_State.faction = UnitFactionGroup("player") or "Horde"
end

-- Appelé quand le joueur est connecté et en jeu
function MBGA_OnPlayerLogin()
    -- Crée la fenêtre principale (définie dans UI/MainFrame.lua)
    MBGA_CreateMainFrame()
end

-- Commande slash pour ouvrir/fermer l'addon
SLASH_MBGA1 = "/mbga"
SLASH_MBGA2 = "/makebgsgreat"
SlashCmdList["MBGA"] = function()
    if MBGA_MainFrame then
        if MBGA_MainFrame:IsShown() then
            MBGA_MainFrame:Hide()
        else
            MBGA_MainFrame:Show()
        end
    end
end
