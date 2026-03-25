"""Réécriture complète de StrategyFrame.lua et MinimapButton.lua"""
import re

# ─── StrategyFrame.lua ───────────────────────────────────────────────────────

stratframe = open("d:/MBGA/UI/StrategyFrame.lua", encoding="utf-8").read()

# 1. Dimensions
stratframe = stratframe.replace(
    "local FRAME_W  = 750\nlocal FRAME_H  = 670",
    "local FRAME_W  = 820\nlocal FRAME_H  = 730"
)

# 2. Police objectif 16 -> 18
stratframe = stratframe.replace(
    'objText:SetFont("Fonts\\\\ARIALN.TTF", 16)',
    'objText:SetFont("Fonts\\\\ARIALN.TTF", 18)'
)

# 3. Police Plan A 13 -> 15
stratframe = stratframe.replace(
    'planAText:SetFont("Fonts\\\\ARIALN.TTF", 13)',
    'planAText:SetFont("Fonts\\\\ARIALN.TTF", 15)'
)

# 4. Police Plan B 12 -> 14
stratframe = stratframe.replace(
    'planBText:SetFont("Fonts\\\\ARIALN.TTF", 12)',
    'planBText:SetFont("Fonts\\\\ARIALN.TTF", 14)'
)

# 5. Police Avoid 12 -> 14
stratframe = stratframe.replace(
    'avoidText:SetFont("Fonts\\\\ARIALN.TTF", 12)',
    'avoidText:SetFont("Fonts\\\\ARIALN.TTF", 14)'
)

# 6. Chips : font 11->13, height 20->26, startY ajusté
stratframe = stratframe.replace(
    '    local chipH   = 20\n    local chipPad = 6   -- padding interne horizontal\n    local chipGap = 5   -- espace entre chips\n    local rowGap  = 5   -- espace entre lignes\n    local startX  = IPAD\n    local startY  = -(IPAD + 16 + 6)  -- sous le label "ROLES UTILES"',
    '    local chipH   = 26\n    local chipPad = 8   -- padding interne horizontal\n    local chipGap = 6   -- espace entre chips\n    local rowGap  = 6   -- espace entre lignes\n    local startX  = IPAD\n    local startY  = -(IPAD + 16 + 8)  -- sous le label "ROLES UTILES"'
)
stratframe = stratframe.replace(
    '        lbl:SetFont("Fonts\\\\ARIALN.TTF", 11)',
    '        lbl:SetFont("Fonts\\\\ARIALN.TTF", 13)'
)
stratframe = stratframe.replace(
    '        local textW = math.max(#role * 7, 30)',
    '        local textW = math.max(#role * 8, 40)'
)
stratframe = stratframe.replace(
    '    local usedH = math.abs(y) + chipH + IPAD\n    if #rolesTable == 0 then usedH = 0 end\n    f.rolesBox.chipsHeight = usedH',
    '    local usedH = math.abs(y) + chipH + IPAD + 6\n    if #rolesTable == 0 then usedH = 0 end\n    f.rolesBox.chipsHeight = usedH'
)

# 7. Réécriture de MBGA_RelayoutStratContent
old_relayout = '''-- ─── Layout dynamique ───────────────────────────────────────────────────────
-- Positionne et redimensionne chaque bloc selon la hauteur du texte mesuré.

function MBGA_RelayoutStratContent()
    local f = MBGA_StratFrame
    if not f then return end
    local content = f.scrollContent
    if not content then return end

    local y = 0  -- curseur Y (valeurs négatives = vers le bas)

    -- Helper : hauteur sûre d'une FontString
    local function safeH(fs, minH)
        local h = fs:GetStringHeight()
        return (h and h > 0) and h or (minH or 12)
    end

    -- ── 1. OBJECTIF ────────────────────────────────────────────────────────
    local objLblH  = 12
    local objTextH = safeH(f.objText, 14)
    local objBoxH  = IPAD + objLblH + 4 + objTextH + IPAD
    f.objBox:ClearAllPoints()
    f.objBox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
    f.objBox:SetHeight(objBoxH)
    y = y - objBoxH - GAP

    -- ── 2. PLAN A (gauche) + PLAN B + À ÉVITER (droite) ───────────────────
    local yColStart = y

    -- Plan A
    local planALblH  = 12
    local planATextH = safeH(f.planAText, 12)
    local planABoxH  = IPAD + planALblH + 5 + planATextH + IPAD

    f.planABox:ClearAllPoints()
    f.planABox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yColStart)
    f.planABox:SetHeight(planABoxH)

    -- Plan B
    local planBLblH  = 12
    local planBTextH = safeH(f.planBText, 11)
    local planBBoxH  = IPAD + planBLblH + 4 + planBTextH + IPAD

    f.planBBox:ClearAllPoints()
    f.planBBox:SetPoint("TOPLEFT", content, "TOPLEFT", COL_A_W + GAP, yColStart)
    f.planBBox:SetHeight(planBBoxH)

    -- À éviter (sous Plan B)
    local avoidVisible = f.avoidBox:IsShown()
    local avoidBoxH = 0
    if avoidVisible then
        local avoidLblH  = 12
        local avoidTextH = safeH(f.avoidText, 11)
        avoidBoxH = IPAD + avoidLblH + 4 + avoidTextH + IPAD
        f.avoidBox:ClearAllPoints()
        f.avoidBox:SetPoint("TOPLEFT", content, "TOPLEFT", COL_A_W + GAP, yColStart - planBBoxH - GAP)
        f.avoidBox:SetHeight(avoidBoxH)
    end

    -- Hauteur totale de la zone à 2 colonnes
    local rightH  = planBBoxH + (avoidVisible and (GAP + avoidBoxH) or 0)
    local colsH   = math.max(planABoxH, rightH)
    y = y - colsH - GAP

    -- ── 3. RÔLES CHIPS ─────────────────────────────────────────────────────
    local rolesH = (f.rolesBox.chipsHeight or 50) + IPAD + 16 + 6
    if rolesH < 40 then rolesH = 40 end
    f.rolesBox:ClearAllPoints()
    f.rolesBox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
    f.rolesBox:SetHeight(rolesH)
    y = y - rolesH - GAP

    -- Hauteur totale du contenu scrollable
    content:SetHeight(math.max(math.abs(y) + PAD, 100))
end'''

new_relayout = '''-- ─── Layout dynamique — remplit tout l'espace disponible ───────────────────
-- 1. Calcule les hauteurs naturelles du texte
-- 2. Distribue l'espace restant : 10% objectif, 75% colonnes, 15% rôles
-- 3. Plan A s'étire pour égaler la hauteur de la colonne droite
-- 4. Plan B s'étire pour remplir le reste de la colonne droite

function MBGA_RelayoutStratContent()
    local f = MBGA_StratFrame
    if not f then return end
    local content = f.scrollContent
    if not content then return end

    -- Helper : hauteur sûre d'une FontString
    local function safeH(fs, minH)
        local h = fs:GetStringHeight()
        return (h and h > 0) and h or (minH or 12)
    end

    -- ── Hauteurs naturelles ─────────────────────────────────────────────────
    local objNat   = IPAD + 14 + 4  + safeH(f.objText,   18) + IPAD
    local planANat = IPAD + 12 + 5  + safeH(f.planAText, 15) + IPAD
    local planBNat = IPAD + 12 + 4  + safeH(f.planBText, 14) + IPAD
    local avoidVis = f.avoidBox:IsShown()
    local avoidNat = avoidVis and (IPAD + 12 + 4 + safeH(f.avoidText, 14) + IPAD) or 0
    local rightNat = planBNat + (avoidVis and (GAP + avoidNat) or 0)
    local colsNat  = math.max(planANat, rightNat)
    local rolesNat = (f.rolesBox.chipsHeight or 70) + IPAD + 16 + 8
    if rolesNat < 70 then rolesNat = 70 end

    -- ── Espace disponible (hauteur du scroll frame) ─────────────────────────
    -- scroll va de (PAD + 64 + 8) px sous le haut jusqu'à (PAD + 4) du bas
    local availH = FRAME_H - (PAD + 64 + 8) - (PAD + 4) - 20

    -- ── Distribution de l'espace extra ──────────────────────────────────────
    local totalNat = objNat + GAP + colsNat + GAP + rolesNat
    local extra    = math.max(availH - totalNat, 0)

    local objBoxH  = objNat   + math.floor(extra * 0.10)
    local colsH    = colsNat  + math.floor(extra * 0.75)
    local rolesH   = rolesNat + math.floor(extra * 0.15)

    -- Plan A s'étire à hauteur totale de la colonne
    local planABoxH = colsH

    -- Plan B s'étire pour remplir la colonne droite au-dessus de Avoid
    local planBBoxH = colsH - (avoidVis and (GAP + avoidNat) or 0)
    if planBBoxH < planBNat then planBBoxH = planBNat end

    -- ── Positionnement ──────────────────────────────────────────────────────
    local y = 0

    f.objBox:ClearAllPoints()
    f.objBox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
    f.objBox:SetHeight(objBoxH)
    y = y - objBoxH - GAP

    local yColStart = y

    f.planABox:ClearAllPoints()
    f.planABox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yColStart)
    f.planABox:SetHeight(planABoxH)

    f.planBBox:ClearAllPoints()
    f.planBBox:SetPoint("TOPLEFT", content, "TOPLEFT", COL_A_W + GAP, yColStart)
    f.planBBox:SetHeight(planBBoxH)

    if avoidVis then
        f.avoidBox:ClearAllPoints()
        f.avoidBox:SetPoint("TOPLEFT", content, "TOPLEFT", COL_A_W + GAP, yColStart - planBBoxH - GAP)
        f.avoidBox:SetHeight(avoidNat)
    end

    y = y - colsH - GAP

    f.rolesBox:ClearAllPoints()
    f.rolesBox:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
    f.rolesBox:SetHeight(rolesH)
    y = y - rolesH - GAP

    -- Hauteur totale du contenu
    content:SetHeight(math.max(math.abs(y) + PAD, availH))
end'''

if old_relayout in stratframe:
    stratframe = stratframe.replace(old_relayout, new_relayout)
    print("RelayoutStratContent replaced OK")
else:
    print("ERROR: Could not find old_relayout in stratframe")
    # Try to find where it starts
    idx = stratframe.find("-- ─── Layout dynamique")
    print(f"  Layout section found at: {idx}")

with open("d:/MBGA/UI/StrategyFrame.lua", "w", encoding="utf-8") as f:
    f.write(stratframe)
print(f"StrategyFrame.lua written: {len(stratframe)} chars")

# ─── MinimapButton.lua ───────────────────────────────────────────────────────

minimap = r"""-- UI/MinimapButton.lua — Bouton minimap rond avec bordure dorée (standard WoW)
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
"""

with open("d:/MBGA/UI/MinimapButton.lua", "w", encoding="utf-8") as f:
    f.write(minimap)
print(f"MinimapButton.lua written: {len(minimap)} chars")
