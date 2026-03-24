-- UI/MainFrame.lua — Fenêtre principale : grille de 15 BGs
-- Wireframe : titre + switches faction/langue + 2 lignes de 5 BGs normaux + 1 ligne de 5 BGs épiques

-- Constantes de design
local FRAME_W       = 620
local FRAME_H       = 480
local CELL_W        = 108
local CELL_H        = 80
local CELL_GAP      = 8
local PADDING       = 16

-- Couleurs sémantiques
local COLOR_HORDE     = { r=0.55, g=0,    b=0 }
local COLOR_ALLIANCE  = { r=0,    g=0.44, b=0.87 }
local COLOR_AMBER     = { r=1,    g=0.65, b=0 }
local COLOR_BG_DARK   = { r=0.10, g=0.10, b=0.12, a=0.95 }
local COLOR_CELL_NORM = { r=0.18, g=0.18, b=0.22, a=0.90 }
local COLOR_CELL_EPIC = { r=0.20, g=0.14, b=0.08, a=0.90 }

-- ─── Création de la frame principale ─────────────────────────────────────────

function MBGA_CreateMainFrame()
    if MBGA_MainFrame then return end

    local f = CreateFrame("Frame", "MBGA_MainFrame", UIParent, "BackdropTemplate")
    f:SetSize(FRAME_W, FRAME_H)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)
    f:SetFrameStrata("HIGH")

    -- Fond
    f:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 26,
        insets = { left=9, right=9, top=9, bottom=9 },
    })
    f:SetBackdropColor(COLOR_BG_DARK.r, COLOR_BG_DARK.g, COLOR_BG_DARK.b, COLOR_BG_DARK.a)

    -- Titre
    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    title:SetPoint("TOP", f, "TOP", 0, -16)
    title:SetText(MBGA_L["TITLE"])
    title:SetTextColor(1, 0.82, 0)

    -- Bouton Fermer
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)

    -- ─── Switches faction ─────────────────────────────────────────────────────
    local hordeBtn = MBGA_CreateFactionButton(f, "Horde", "LEFT",  -120, -18)
    local allBtn   = MBGA_CreateFactionButton(f, "Alliance", "RIGHT", 120, -18)

    -- ─── Switch langue ────────────────────────────────────────────────────────
    local langFR = MBGA_CreateLangButton(f, "FR", -18, -18)
    local langEN = MBGA_CreateLangButton(f, "EN",  18, -18)

    -- ─── Séparateur ───────────────────────────────────────────────────────────
    local sep = f:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(0.4, 0.4, 0.4, 0.5)
    sep:SetSize(FRAME_W - 32, 1)
    sep:SetPoint("TOP", f, "TOP", 0, -46)

    -- ─── Catégories + grilles ─────────────────────────────────────────────────
    -- Normaux
    local catNormal = f:CreateFontString(nil, "OVERLAY")
    catNormal:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    catNormal:SetPoint("TOPLEFT", f, "TOPLEFT", PADDING, -56)
    catNormal:SetTextColor(0.75, 0.75, 0.75)
    catNormal:SetText(MBGA_L["CAT_NORMAL"])

    -- Ligne 1 (BGs 1-5)
    local row1Y = -74
    for i = 1, 5 do
        MBGA_CreateBGCell(f, i, i, row1Y)
    end
    -- Ligne 2 (BGs 6-10)
    local row2Y = row1Y - CELL_H - CELL_GAP
    for i = 6, 10 do
        MBGA_CreateBGCell(f, i, i - 5, row2Y)
    end

    -- Séparateur épiques
    local sep2 = f:CreateTexture(nil, "ARTWORK")
    sep2:SetColorTexture(0.4, 0.4, 0.4, 0.5)
    sep2:SetSize(FRAME_W - 32, 1)
    sep2:SetPoint("TOPLEFT", f, "TOPLEFT", PADDING, row2Y - CELL_H - 4)

    -- Épiques
    local catEpic = f:CreateFontString(nil, "OVERLAY")
    catEpic:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    catEpic:SetPoint("TOPLEFT", f, "TOPLEFT", PADDING, row2Y - CELL_H - 8)
    catEpic:SetTextColor(0.75, 0.75, 0.75)
    catEpic:SetText(MBGA_L["CAT_EPIC"])

    local row3Y = row2Y - CELL_H - CELL_GAP - 20
    for i = 11, 15 do
        MBGA_CreateBGCell(f, i, i - 10, row3Y)
    end

    -- Mise à jour de l'affichage selon la faction initiale
    MBGA_UpdateFactionUI()
end

-- ─── Cellule d'un BG dans la grille ──────────────────────────────────────────

function MBGA_CreateBGCell(parent, bgIndex, col, rowY)
    local bg = MBGA_BGs[bgIndex]
    if not bg then return end

    local xOffset = PADDING + (col - 1) * (CELL_W + CELL_GAP)
    local isEpic  = bg.isEpic

    local cell = CreateFrame("Button", "MBGA_Cell_" .. bg.id, parent, "BackdropTemplate")
    cell:SetSize(CELL_W, CELL_H)
    cell:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, rowY)

    cell:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left=3, right=3, top=3, bottom=3 },
    })

    local c = isEpic and COLOR_CELL_EPIC or COLOR_CELL_NORM
    cell:SetBackdropColor(c.r, c.g, c.b, c.a)

    -- Nom du BG
    local label = cell:CreateFontString(nil, "OVERLAY")
    label:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE")
    label:SetPoint("CENTER", cell, "CENTER", 0, 0)
    label:SetSize(CELL_W - 8, 0)
    label:SetJustifyH("CENTER")
    label:SetJustifyV("MIDDLE")
    label:SetTextColor(1, 1, 1)
    label:SetText(MBGA_L[bg.nameKey] or bg.id)

    -- Format (petit texte secondaire)
    local fmt = cell:CreateFontString(nil, "OVERLAY")
    fmt:SetFont("Fonts\\ARIALN.TTF", 9)
    fmt:SetPoint("BOTTOM", cell, "BOTTOM", 0, 6)
    fmt:SetTextColor(0.6, 0.6, 0.6)
    fmt:SetText(bg.format or "")

    -- Highlight au survol
    cell:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")

    -- Script de clic → ouvre la fiche stratégie
    cell:SetScript("OnClick", function()
        MBGA_OpenStrategyFrame(bgIndex)
    end)

    -- Stockage de la référence pour mise à jour faction
    cell.bgIndex = bgIndex
    cell.label   = label
end

-- ─── Bouton de faction ───────────────────────────────────────────────────────

function MBGA_CreateFactionButton(parent, faction, point, xOff, yOff)
    local btn = CreateFrame("Button", "MBGA_Btn_" .. faction, parent, "BackdropTemplate")
    btn:SetSize(80, 22)
    btn:SetPoint(point, parent, "TOP", xOff, yOff)

    btn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left=3, right=3, top=3, bottom=3 },
    })

    local label = btn:CreateFontString(nil, "OVERLAY")
    label:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE")
    label:SetAllPoints()
    label:SetJustifyH("CENTER")
    label:SetJustifyV("MIDDLE")
    label:SetText(faction == "Horde" and ("🔴 " .. MBGA_L["FACTION_HORDE"]) or ("🔵 " .. MBGA_L["FACTION_ALLIANCE"]))
    btn.label = label

    btn:SetScript("OnClick", function()
        MBGA_State.faction = faction
        MBGA_UpdateFactionUI()
    end)

    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    return btn
end

-- ─── Bouton de langue ────────────────────────────────────────────────────────

function MBGA_CreateLangButton(parent, lang, xOff, yOff)
    local btn = CreateFrame("Button", "MBGA_Btn_Lang" .. lang, parent, "BackdropTemplate")
    btn:SetSize(32, 22)
    btn:SetPoint("TOP", parent, "TOP", xOff, yOff)

    btn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left=3, right=3, top=3, bottom=3 },
    })

    local label = btn:CreateFontString(nil, "OVERLAY")
    label:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE")
    label:SetAllPoints()
    label:SetJustifyH("CENTER")
    label:SetJustifyV("MIDDLE")
    label:SetText(MBGA_L["LANG_" .. lang])
    btn.label = label

    btn:SetScript("OnClick", function()
        MBGA_SwitchLocale(lang)
        MBGA_UpdateLangUI()
    end)

    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    return btn
end

-- ─── Mise à jour visuelle faction ────────────────────────────────────────────

function MBGA_UpdateFactionUI()
    local isHorde = (MBGA_State.faction == "Horde")

    -- Couleur de la bordure de la MainFrame
    local c = isHorde and COLOR_HORDE or COLOR_ALLIANCE
    if MBGA_MainFrame then
        MBGA_MainFrame:SetBackdropBorderColor(c.r, c.g, c.b, 1)
    end

    -- Surbrillance du bouton actif
    local hBtn = _G["MBGA_Btn_Horde"]
    local aBtn = _G["MBGA_Btn_Alliance"]
    if hBtn then
        local a = isHorde and 1 or 0.4
        hBtn:SetBackdropColor(COLOR_HORDE.r * a, COLOR_HORDE.g * a, COLOR_HORDE.b * a, 0.9)
    end
    if aBtn then
        local a = isHorde and 0.4 or 1
        aBtn:SetBackdropColor(COLOR_ALLIANCE.r * a, COLOR_ALLIANCE.g * a, COLOR_ALLIANCE.b * a, 0.9)
    end

    -- Si la fiche stratégie est ouverte, la mettre à jour aussi
    if MBGA_StratFrame and MBGA_StratFrame:IsShown() then
        MBGA_UpdateStratContent()
    end
end

-- ─── Mise à jour visuelle langue ─────────────────────────────────────────────

function MBGA_UpdateLangUI()
    local isFR = (MBGA_State.lang == "FR")

    local frBtn = _G["MBGA_Btn_LangFR"]
    local enBtn = _G["MBGA_Btn_LangEN"]
    if frBtn then
        frBtn:SetBackdropColor(isFR and 0.3 or 0.1, isFR and 0.3 or 0.1, isFR and 0.3 or 0.1, 0.9)
    end
    if enBtn then
        enBtn:SetBackdropColor(isFR and 0.1 or 0.3, isFR and 0.1 or 0.3, isFR and 0.1 or 0.3, 0.9)
    end

    -- Si la fiche stratégie est ouverte, la mettre à jour aussi
    if MBGA_StratFrame and MBGA_StratFrame:IsShown() then
        MBGA_UpdateStratContent()
    end
end
