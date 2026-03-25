-- UI/MinimapButton.lua — Bouton minimap draggable (standard WoW addon pattern)
-- Icône ronde positionnée autour de la minimap, draggable, avec tooltip
-- Position sauvegardée dans MBGA_MinimapAngle (SavedVariables dans .toc)

local DEFAULT_ANGLE = 225  -- bas-gauche par défaut

-- ─── Calcul de position autour de la minimap ─────────────────────────────────

local function GetMinimapXY(angle)
    -- Rayon = 80 : valeur standard pour boutons autour de la minimap (120px diameter)
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
    -- Éviter la double création
    if MBGA_MinimapButton then return end

    -- Initialisation de l'angle sauvegardé (SavedVariables)
    if not MBGA_MinimapAngle then MBGA_MinimapAngle = DEFAULT_ANGLE end

    local btn = CreateFrame("Button", "MBGA_MinimapButton", Minimap)
    btn:SetSize(32, 32)
    btn:SetFrameStrata("MEDIUM")
    btn:SetFrameLevel(8)

    -- Icône de l'addon (cercle grâce au masque circulaire standard)
    local icon = btn:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\AddOns\\MBGA\\Assets\\Mrrglgamesh_icon")
    icon:SetSize(24, 24)
    icon:SetPoint("CENTER")

    -- Bordure ronde standard (donne l'aspect bouton minimap classique)
    local border = btn:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetSize(56, 56)
    border:SetPoint("TOPLEFT", btn, "TOPLEFT", -12, 12)

    -- Highlight au survol
    btn:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    -- Position initiale
    UpdateMinimapButtonPos(btn)

    -- ─── Drag autour de la minimap ───────────────────────────────────────────
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
        GameTooltip:AddLine(" ", 1, 1, 1)
        GameTooltip:AddLine("/mbga  -  Ouvrir la fenetre", 0.72, 0.78, 0.95)
        GameTooltip:AddLine("/mbga strat  -  Parler dans le raid (bientot)", 0.55, 0.62, 0.80)
        GameTooltip:Show()
    end)

    btn:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    -- ─── Clic gauche : toggle fenêtre principale ─────────────────────────────
    btn:SetScript("OnClick", function(self, button)
        if button ~= "LeftButton" then return end

        -- Si la StratFrame est ouverte, on la ferme et on ouvre la MainFrame
        if MBGA_StratFrame and MBGA_StratFrame:IsShown() then
            MBGA_StratFrame:Hide()
            return
        end

        -- Toggle la fenêtre principale
        if MBGA_MainFrame then
            if MBGA_MainFrame:IsShown() then
                MBGA_MainFrame:Hide()
            else
                MBGA_MainFrame:Show()
            end
        end
    end)
end
