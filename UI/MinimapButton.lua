-- UI/MinimapButton.lua — Bouton minimap rond avec bordure dorée (standard WoW)
-- Pattern utilisé par Details!, BigWigs, WeakAuras etc.
-- Icône ronde positionnée autour de la minimap, draggable, tooltip complet.
-- Position sauvegardée dans MBGA_MinimapAngle (SavedVariables).

local DEFAULT_ANGLE = 225  -- bas-gauche de la minimap par défaut

-- ─── Position autour de la minimap ───────────────────────────────────────────
-- Rayon 80 = distance standard pour les boutons addon autour de la minimap

local function GetMinimapXY(angle)
    return math.cos(math.rad(angle)) * 80, math.sin(math.rad(angle)) * 80
end

local function UpdateMinimapButtonPos(btn)
    if not MBGA_MinimapAngle then MBGA_MinimapAngle = DEFAULT_ANGLE end
    local x, y = GetMinimapXY(MBGA_MinimapAngle)
    btn:ClearAllPoints()
    btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

-- ─── Création du bouton ───────────────────────────────────────────────────────

function MBGA_CreateMinimapButton()
    if MBGA_MinimapButton then return end
    if not MBGA_MinimapAngle then MBGA_MinimapAngle = DEFAULT_ANGLE end

    local btn = CreateFrame("Button", "MBGA_MinimapButton", Minimap)
    btn:SetSize(32, 32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)

    -- Fond sombre circulaire (couche BACKGROUND)
    local bg = btn:CreateTexture(nil, "BACKGROUND")
    bg:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    bg:SetAllPoints()

    -- Icône de l'addon (couche ARTWORK)
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\AddOns\\MBGA\\assets\\Mrrglgamesh_icon")
    icon:SetSize(22, 22)
    icon:SetPoint("CENTER", btn, "CENTER", 0, 0)

    -- Masque circulaire sur l'icône (crop propre, standard WoW portrait)
    local iconMask = btn:CreateMaskTexture()
    iconMask:SetTexture(
        "Interface\\CharacterFrame\\TempPortraitAlphaMask",
        "CLAMPTOBLACKADDITIVE",
        "CLAMPTOBLACKADDITIVE"
    )
    iconMask:SetAllPoints(icon)
    icon:AddMaskTexture(iconMask)

    -- Bordure dorée (MiniMap-TrackingBorder = l'anneau doré standard des addons)
    -- Taille 56x56 pour un bouton 32x32, offset (-12, 12) pour centrer
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(56, 56)
    border:SetPoint("TOPLEFT", btn, "TOPLEFT", -12, 12)

    -- Highlight au survol (ring lumineux standard)
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Position initiale autour de la minimap
    UpdateMinimapButtonPos(btn)

    -- ─── Drag pour repositionner autour de la minimap ────────────────────────

    btn:RegisterForDrag("LeftButton")

    btn:SetScript("OnDragStart", function(self)
        self:SetScript("OnUpdate", function()
            local mx, my = Minimap:GetCenter()
            local cx, cy = GetCursorPosition()
            local scale  = UIParent:GetEffectiveScale()
            cx = cx / scale
            cy = cy / scale
            MBGA_MinimapAngle = math.deg(math.atan2(cy - my, cx - mx))
            UpdateMinimapButtonPos(self)
        end)
    end)

    btn:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
    end)

    -- ─── Tooltip ────────────────────────────────────────────────────────────

    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("Make BG's Great Again", 1, 0.82, 0)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("/mbga            Ouvrir / fermer", 0.72, 0.78, 0.95)
        GameTooltip:AddLine("/mbga strat      Parler dans le raid (bientot)", 0.55, 0.62, 0.80)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- ─── Clic gauche : toggle de la fenêtre principale ───────────────────────

    btn:SetScript("OnClick", function(self, button)
        if button ~= "LeftButton" then return end
        -- Ferme la StratFrame si elle est ouverte
        if MBGA_StratFrame and MBGA_StratFrame:IsShown() then
            MBGA_StratFrame:Hide()
            return
        end
        -- Toggle la MainFrame
        if MBGA_MainFrame then
            if MBGA_MainFrame:IsShown() then
                MBGA_MainFrame:Hide()
            else
                MBGA_MainFrame:Show()
            end
        end
    end)
end
