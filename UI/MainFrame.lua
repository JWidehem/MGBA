-- UI/MainFrame.lua — Fenêtre principale : grille de 15 BGs
-- Header : titre centré + boutons Horde/Alliance sur les côtés + FR/EN en dessous

-- Constantes de design
-- PADDING = (FRAME_W - (5*CELL_W + 4*CELL_GAP)) / 2 = (690 - 632) / 2 = 29 → grille centrée
local FRAME_W    = 690
local FRAME_H    = 430
local CELL_W     = 120
local CELL_H     = 90
local CELL_GAP   = 8
local PADDING    = 29

-- Couleurs sémantiques
local COLOR_HORDE     = { r=0.55, g=0,    b=0    }
local COLOR_ALLIANCE  = { r=0,    g=0.44, b=0.87 }
local COLOR_BG_DARK   = { r=0.09, g=0.09, b=0.11, a=0.97 }
local COLOR_CELL_NORM = { r=0.16, g=0.16, b=0.20, a=0.92 }
local COLOR_CELL_EPIC = { r=0.20, g=0.13, b=0.05, a=0.92 }

-- Références locales pour rafraîchir les textes après switch de locale
local frameLabels = { cells = {} }

-- ─── Rafraîchissement des textes après switch de locale ──────────────────────
-- Appelé depuis MBGA_SwitchLocale() (MBGA.lua) et MBGA_UpdateLangUI()

function MBGA_RefreshMainFrameLabels()
    local lb = frameLabels
    if lb.title      then lb.title:SetText(MBGA_L["TITLE"]           or "Make BG's Great Again") end
    if lb.catNormal  then lb.catNormal:SetText(MBGA_L["CAT_NORMAL"]  or "") end
    if lb.catEpic    then lb.catEpic:SetText(MBGA_L["CAT_EPIC"]      or "") end
    if lb.hordeLabel then lb.hordeLabel:SetText(MBGA_L["FACTION_HORDE"]   or "Horde")    end
    if lb.alliLabel  then lb.alliLabel:SetText(MBGA_L["FACTION_ALLIANCE"] or "Alliance") end
    -- Noms complets des BGs dans les cellules
    for bgIndex, cellLabel in pairs(lb.cells) do
        local bg = MBGA_BGs[bgIndex]
        if bg then
            cellLabel:SetText(MBGA_L[bg.nameKey] or bg.id)
        end
    end
end

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

    -- Fond principal
    f:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 26,
        insets = { left=9, right=9, top=9, bottom=9 },
    })
    f:SetBackdropColor(COLOR_BG_DARK.r, COLOR_BG_DARK.g, COLOR_BG_DARK.b, COLOR_BG_DARK.a)

    -- ─── ZONE HEADER ─────────────────────────────────────────────────────────

    -- Bouton Fermer (haut droite)
    local closeBtn = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)

    -- Boutons faction (Horde gauche, Alliance droite à gauche du X)
    MBGA_CreateFactionButton(f, "Horde")
    MBGA_CreateFactionButton(f, "Alliance")

    -- Titre centré (Friz Quadrata — fonte WoW emblématique)
    local title = f:CreateFontString(nil, "OVERLAY")
    title:SetFont("Fonts\\FRIZQT__.TTF", 17, "OUTLINE")
    title:SetPoint("TOP", f, "TOP", 0, -14)
    title:SetText(MBGA_L["TITLE"] or "Make BG's Great Again")
    title:SetTextColor(1, 0.82, 0)
    frameLabels.title = title

    -- ─── Switch langue (2e rangée, centré) ───────────────────────────────────
    MBGA_CreateLangButton(f, "FR", -22, -44)
    MBGA_CreateLangButton(f, "EN",  22, -44)

    -- Séparateur "/" entre FR et EN
    local slash = f:CreateFontString(nil, "OVERLAY")
    slash:SetFont("Fonts\\ARIALN.TTF", 14, "OUTLINE")
    slash:SetPoint("TOP", f, "TOP", 0, -46)
    slash:SetText("/")
    slash:SetTextColor(0.45, 0.45, 0.45)

    -- ─── Ligne de séparation sous le header ──────────────────────────────────
    local sep1 = f:CreateTexture(nil, "ARTWORK")
    sep1:SetColorTexture(0.4, 0.4, 0.4, 0.5)
    sep1:SetSize(FRAME_W - 2 * PADDING, 1)  -- centré = largeur exacte de la grille
    sep1:SetPoint("TOP", f, "TOP", 0, -66)

    -- ─── Catégorie NORMAUX ────────────────────────────────────────────────────
    local catNormal = f:CreateFontString(nil, "OVERLAY")
    catNormal:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    catNormal:SetPoint("TOPLEFT", f, "TOPLEFT", PADDING, -74)
    catNormal:SetTextColor(0.65, 0.65, 0.65)
    catNormal:SetText(MBGA_L["CAT_NORMAL"] or "")
    frameLabels.catNormal = catNormal

    -- Ligne 1 — BGs 1 à 5
    local row1Y = -90
    for i = 1, 5 do
        MBGA_CreateBGCell(f, i, i, row1Y)
    end

    -- Ligne 2 — BGs 6 à 10
    local row2Y = row1Y - CELL_H - CELL_GAP
    for i = 6, 10 do
        MBGA_CreateBGCell(f, i, i - 5, row2Y)
    end

    -- ─── Séparation épiques (teinte dorée) ───────────────────────────────────
    local sep2 = f:CreateTexture(nil, "ARTWORK")
    sep2:SetColorTexture(0.55, 0.40, 0.10, 0.6)
    sep2:SetSize(FRAME_W - 2 * PADDING, 1)  -- même largeur que la grille
    sep2:SetPoint("TOPLEFT", f, "TOPLEFT", PADDING, row2Y - CELL_H - 8)

    -- ─── Catégorie ÉPIQUES (teinte dorée pour distinguer) ────────────────────
    local catEpic = f:CreateFontString(nil, "OVERLAY")
    catEpic:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    catEpic:SetPoint("TOPLEFT", f, "TOPLEFT", PADDING, row2Y - CELL_H - 12)
    catEpic:SetTextColor(0.85, 0.65, 0.20)
    catEpic:SetText(MBGA_L["CAT_EPIC"] or "")
    frameLabels.catEpic = catEpic

    -- Ligne 3 — BGs épiques 11 à 15
    local row3Y = row2Y - CELL_H - CELL_GAP - 24
    for i = 11, 15 do
        MBGA_CreateBGCell(f, i, i - 10, row3Y)
    end

    -- Mise à jour visuelle initiale (couleurs faction + état langue)
    MBGA_UpdateFactionUI()
    MBGA_UpdateLangUI()

    -- Cachée au démarrage — le joueur l'ouvre via /mbga
    f:Hide()
end

-- ─── Cellule d'un BG dans la grille ──────────────────────────────────────────

function MBGA_CreateBGCell(parent, bgIndex, col, rowY)
    local bg = MBGA_BGs[bgIndex]
    if not bg then return end

    local xOffset = PADDING + (col - 1) * (CELL_W + CELL_GAP)

    local cell = CreateFrame("Button", "MBGA_Cell_" .. bg.id, parent, "BackdropTemplate")
    cell:SetSize(CELL_W, CELL_H)
    cell:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, rowY)

    cell:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left=3, right=3, top=3, bottom=3 },
    })
    local c = bg.isEpic and COLOR_CELL_EPIC or COLOR_CELL_NORM
    cell:SetBackdropColor(c.r, c.g, c.b, c.a)

    -- Nom complet du BG (centré, 2 lignes possibles pour les noms longs)
    local label = cell:CreateFontString(nil, "OVERLAY")
    label:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE")
    label:SetPoint("CENTER", cell, "CENTER", 0, 8)
    label:SetSize(CELL_W - 10, 38)
    label:SetJustifyH("CENTER")
    label:SetJustifyV("MIDDLE")
    label:SetTextColor(1, 1, 1)
    label:SetText(MBGA_L[bg.nameKey] or bg.id)

    -- Stocker la référence pour le rafraîchissement de locale
    frameLabels.cells[bgIndex] = label

    -- Format sous le nom (petit, discret)
    local fmt = cell:CreateFontString(nil, "OVERLAY")
    fmt:SetFont("Fonts\\ARIALN.TTF", 9)
    fmt:SetPoint("BOTTOM", cell, "BOTTOM", 0, 6)
    fmt:SetTextColor(0.50, 0.50, 0.50)
    fmt:SetText(bg.format or "")

    -- Highlight standard WoW au survol
    cell:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")

    -- Clic → ouvre la fiche stratégie
    cell:SetScript("OnClick", function()
        MBGA_OpenStrategyFrame(bgIndex)
    end)

    cell.bgIndex = bgIndex
    cell.label   = label
end

-- ─── Bouton de faction ───────────────────────────────────────────────────────

function MBGA_CreateFactionButton(parent, faction)
    local btn = CreateFrame("Button", "MBGA_Btn_" .. faction, parent, "BackdropTemplate")
    btn:SetSize(95, 26)

    if faction == "Horde" then
        btn:SetPoint("TOPLEFT", parent, "TOPLEFT", PADDING, -12)
    else
        -- Alliance : à gauche du bouton Fermer (34px de décalage depuis TOPRIGHT)
        btn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -34, -12)
    end

    btn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left=3, right=3, top=3, bottom=3 },
    })

    local label = btn:CreateFontString(nil, "OVERLAY")
    label:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    label:SetAllPoints()
    label:SetJustifyH("CENTER")
    label:SetJustifyV("MIDDLE")

    if faction == "Horde" then
        label:SetText(MBGA_L["FACTION_HORDE"] or "Horde")
        label:SetTextColor(1, 0.35, 0.35)
        frameLabels.hordeLabel = label
    else
        label:SetText(MBGA_L["FACTION_ALLIANCE"] or "Alliance")
        label:SetTextColor(0.35, 0.65, 1)
        frameLabels.alliLabel = label
    end
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
    btn:SetSize(36, 22)
    btn:SetPoint("TOP", parent, "TOP", xOff, yOff)

    btn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left=3, right=3, top=3, bottom=3 },
    })

    local label = btn:CreateFontString(nil, "OVERLAY")
    label:SetFont("Fonts\\ARIALN.TTF", 13, "OUTLINE")
    label:SetAllPoints()
    label:SetJustifyH("CENTER")
    label:SetJustifyV("MIDDLE")
    label:SetTextColor(1, 1, 1)
    -- "FR" / "EN" sont des valeurs fixes — pas de traduction nécessaire
    label:SetText(lang)

    if lang == "FR" then
        frameLabels.langFRLabel = label
    else
        frameLabels.langENLabel = label
    end
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

    -- Couleur de la bordure de la frame selon la faction active
    local c = isHorde and COLOR_HORDE or COLOR_ALLIANCE
    if MBGA_MainFrame then
        MBGA_MainFrame:SetBackdropBorderColor(c.r, c.g, c.b, 1)
    end

    -- Bouton actif : fond coloré fort ; inactif : fond très sombre
    local hBtn = _G["MBGA_Btn_Horde"]
    local aBtn = _G["MBGA_Btn_Alliance"]
    if hBtn then
        if isHorde then
            hBtn:SetBackdropColor(COLOR_HORDE.r * 0.6, 0, 0, 0.95)
        else
            hBtn:SetBackdropColor(0.12, 0.06, 0.06, 0.9)
        end
    end
    if aBtn then
        if not isHorde then
            aBtn:SetBackdropColor(0, COLOR_ALLIANCE.g * 0.3, COLOR_ALLIANCE.b * 0.3, 0.95)
        else
            aBtn:SetBackdropColor(0.06, 0.06, 0.12, 0.9)
        end
    end

    -- Si la fiche stratégie est ouverte, la mettre à jour aussi
    if MBGA_StratFrame and MBGA_StratFrame:IsShown() then
        MBGA_UpdateStratContent()
    end
end

-- ─── Mise à jour visuelle langue ─────────────────────────────────────────────

function MBGA_UpdateLangUI()
    local isFR = (MBGA_State.lang == "FR")

    -- Bouton actif : fond plus clair ; inactif : fond sombre
    local frBtn = _G["MBGA_Btn_LangFR"]
    local enBtn = _G["MBGA_Btn_LangEN"]
    if frBtn then
        local v = isFR and 0.32 or 0.10
        frBtn:SetBackdropColor(v, v, v, 0.9)
    end
    if enBtn then
        local v = isFR and 0.10 or 0.32
        enBtn:SetBackdropColor(v, v, v, 0.9)
    end

    -- Rafraîchir tous les textes traduits
    MBGA_RefreshMainFrameLabels()

    -- Sync les boutons FR/EN de la StratFrame si elle existe
    if MBGA_UpdateStratLangUI then
        MBGA_UpdateStratLangUI()
    end

    -- Si la fiche stratégie est ouverte, la mettre à jour
    if MBGA_StratFrame and MBGA_StratFrame:IsShown() then
        MBGA_UpdateStratContent()
    end
end
