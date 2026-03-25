-- UI/StrategyFrame.lua — Fiche stratégie redessinée
-- Layout inspiré du mockup : Header / Objectif / Plan A+B côte à côte / A éviter / Rôles chips
--
-- HEADER  : badge type | nom grand | format sous-titre | boutons FR/EN | retour
-- OBJECTIF: pleine largeur, texte grand italique
-- PLAN A  : ~60% gauche, steps numérotés
-- PLAN B  : ~40% droite, prose
-- A EVITER: ~40% droite sous Plan B, fond rose
-- ROLES   : pleine largeur, chips dark-mode

local FRAME_W  = 750
local FRAME_H  = 670
local PAD      = 14   -- padding extérieur frame
local IPAD     = 12   -- padding interne des blocs
local GAP      = 10   -- espace vertical entre blocs

-- Largeur utile (frame - 2*PAD - scrollbar)
local CWIDTH   = FRAME_W - 2 * PAD - 22
-- Colonnes Plan A / Plan B+Avoid (ratio ~60/40)
local COL_A_W  = math.floor(CWIDTH * 0.58) - 4
local COL_B_W  = CWIDTH - COL_A_W - GAP

-- Couleurs blocs
local C_HEADER_BG   = { 0.11, 0.12, 0.16, 1.00 }
local C_OBJ_BG      = { 0.13, 0.14, 0.19, 1.00 }
local C_OBJ_BD      = { 0.28, 0.30, 0.42, 1.00 }
local C_PLAN_BG     = { 0.13, 0.14, 0.19, 1.00 }
local C_PLAN_BD     = { 0.28, 0.30, 0.42, 1.00 }
local C_AVOID_BG    = { 0.22, 0.10, 0.12, 1.00 }  -- teinte rose sombre
local C_AVOID_BD    = { 0.55, 0.18, 0.22, 1.00 }
local C_ROLES_BG    = { 0.11, 0.12, 0.16, 1.00 }
local C_ROLES_BD    = { 0.28, 0.30, 0.42, 1.00 }
local C_CHIP_BG     = { 0.18, 0.19, 0.26, 1.00 }
local C_CHIP_BD     = { 0.35, 0.37, 0.52, 1.00 }

-- Couleurs texte
local C_BADGE_NORM  = { 0.99, 0.65, 0.10 }   -- orange pour BG Normal
local C_BADGE_EPIC  = { 0.52, 0.72, 1.00 }   -- bleu clair pour BG Epique
local C_SECTION_LBL = { 0.52, 0.72, 1.00 }   -- bleu section label
local C_AVOID_LBL   = { 0.95, 0.38, 0.42 }   -- rouge clair label "A EVITER"
local C_OBJ_TEXT    = { 0.78, 0.82, 1.00 }   -- lavande clair objectif
local C_BODY        = { 0.84, 0.86, 0.92 }   -- texte corps
local C_AVOID_TEXT  = { 0.90, 0.70, 0.72 }   -- texte à éviter (rosé)
local C_CHIP_TEXT   = { 0.88, 0.90, 0.95 }   -- texte chips

-- Index du BG actuellement affiché
local currentBGIndex = nil

-- ─── Utilitaire backdrop ────────────────────────────────────────────────────

local function ApplyBackdrop(frame, bg, bd)
    frame:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left=4, right=4, top=4, bottom=4 },
    })
    frame:SetBackdropColor(bg[1], bg[2], bg[3], bg[4])
    frame:SetBackdropBorderColor(bd[1], bd[2], bd[3], bd[4])
end

-- ─── Ouverture de la fiche ──────────────────────────────────────────────────

function MBGA_OpenStrategyFrame(bgIndex)
    currentBGIndex = bgIndex
    if not MBGA_StratFrame then
        MBGA_BuildStratFrame()
    end
    MBGA_StratFrame:Show()
    if MBGA_MainFrame then MBGA_MainFrame:Hide() end
    MBGA_UpdateStratContent()
end

-- ─── Construction de la frame (une seule fois) ─────────────────────────────

function MBGA_BuildStratFrame()
    local f = CreateFrame("Frame", "MBGA_StratFrame", UIParent, "BackdropTemplate")
    f:SetSize(FRAME_W, FRAME_H)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)
    f:SetFrameStrata("HIGH")
    f:Hide()

    f:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 26,
        insets = { left=9, right=9, top=9, bottom=9 },
    })
    f:SetBackdropColor(0.08, 0.09, 0.12, 0.97)

    -- ─── HEADER ZONE ───────────────────────────────────────────────────────
    local hdr = CreateFrame("Frame", nil, f, "BackdropTemplate")
    hdr:SetPoint("TOPLEFT",     f, "TOPLEFT",     PAD, -PAD)
    hdr:SetPoint("TOPRIGHT",    f, "TOPRIGHT",   -PAD, -PAD)
    hdr:SetHeight(64)
    hdr:SetBackdrop({
        bgFile  = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 6,
        insets = { left=3, right=3, top=3, bottom=3 },
    })
    hdr:SetBackdropColor(C_HEADER_BG[1], C_HEADER_BG[2], C_HEADER_BG[3], C_HEADER_BG[4])
    hdr:SetBackdropBorderColor(0.22, 0.24, 0.32, 1)

    -- Bouton Retour
    local backBtn = CreateFrame("Button", nil, hdr, "BackdropTemplate")
    backBtn:SetSize(80, 24)
    backBtn:SetPoint("TOPLEFT", hdr, "TOPLEFT", IPAD, -IPAD)
    ApplyBackdrop(backBtn, { 0.16, 0.17, 0.23, 1 }, { 0.30, 0.32, 0.45, 1 })
    local backLabel = backBtn:CreateFontString(nil, "OVERLAY")
    backLabel:SetFont("Fonts\\ARIALN.TTF", 12)
    backLabel:SetAllPoints()
    backLabel:SetJustifyH("CENTER")
    backLabel:SetJustifyV("MIDDLE")
    backLabel:SetTextColor(0.72, 0.78, 0.95)
    backLabel:SetText("< Retour")
    backBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    backBtn:SetScript("OnClick", function()
        MBGA_StratFrame:Hide()
        if MBGA_MainFrame then MBGA_MainFrame:Show() end
    end)
    f.backLabel = backLabel

    -- Badge type (BG Normal / BG Epique)
    local badge = hdr:CreateFontString(nil, "OVERLAY")
    badge:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE")
    badge:SetPoint("TOPLEFT", hdr, "TOPLEFT", IPAD, -40)
    badge:SetTextColor(C_BADGE_NORM[1], C_BADGE_NORM[2], C_BADGE_NORM[3])
    f.badge = badge

    -- Nom du BG (grand)
    local bgTitle = hdr:CreateFontString(nil, "OVERLAY")
    bgTitle:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE")
    bgTitle:SetPoint("TOP", hdr, "TOP", 0, -8)
    bgTitle:SetTextColor(0.95, 0.97, 1.00)
    f.bgTitle = bgTitle

    -- Sous-titre format
    local bgFormat = hdr:CreateFontString(nil, "OVERLAY")
    bgFormat:SetFont("Fonts\\ARIALN.TTF", 11)
    bgFormat:SetPoint("TOP", bgTitle, "BOTTOM", 0, -2)
    bgFormat:SetTextColor(0.55, 0.60, 0.78)
    f.bgFormat = bgFormat

    -- Boutons FR / EN
    MBGA_BuildStratLangBtn(f, hdr, "FR", -(IPAD + 38), -IPAD)
    MBGA_BuildStratLangBtn(f, hdr, "EN", -IPAD,         -IPAD)

    -- Ligne séparation header / scroll
    local sep = f:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(0.22, 0.24, 0.32, 0.8)
    sep:SetHeight(1)
    sep:SetPoint("TOPLEFT",  f, "TOPLEFT",  PAD,  -(PAD + 64 + 4))
    sep:SetPoint("TOPRIGHT", f, "TOPRIGHT", -PAD, -(PAD + 64 + 4))

    -- ─── SCROLL FRAME ──────────────────────────────────────────────────────
    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",     f, "TOPLEFT",     PAD,        -(PAD + 64 + 8))
    scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -(PAD + 20), PAD + 4)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(CWIDTH)
    content:SetHeight(900)
    scroll:SetScrollChild(content)
    f.scrollContent = content

    -- ─── BLOC OBJECTIF ─────────────────────────────────────────────────────
    local objBox = CreateFrame("Frame", nil, content, "BackdropTemplate")
    objBox:SetWidth(CWIDTH)
    objBox:SetHeight(60)
    ApplyBackdrop(objBox, C_OBJ_BG, C_OBJ_BD)

    local objLbl = objBox:CreateFontString(nil, "OVERLAY")
    objLbl:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    objLbl:SetTextColor(C_SECTION_LBL[1], C_SECTION_LBL[2], C_SECTION_LBL[3])
    objLbl:SetPoint("TOPLEFT", objBox, "TOPLEFT", IPAD, -IPAD)
    objLbl:SetText("OBJECTIF")

    local objText = objBox:CreateFontString(nil, "OVERLAY")
    objText:SetFont("Fonts\\ARIALN.TTF", 16)
    objText:SetTextColor(C_OBJ_TEXT[1], C_OBJ_TEXT[2], C_OBJ_TEXT[3])
    objText:SetJustifyH("LEFT")
    objText:SetJustifyV("TOP")
    objText:SetNonSpaceWrap(true)
    objText:SetWidth(CWIDTH - 2 * IPAD)
    objText:SetPoint("TOPLEFT", objLbl, "BOTTOMLEFT", 0, -4)
    f.objBox  = objBox
    f.objText = objText

    -- ─── COLONNE GAUCHE : PLAN A ────────────────────────────────────────────
    local planABox = CreateFrame("Frame", nil, content, "BackdropTemplate")
    planABox:SetWidth(COL_A_W)
    planABox:SetHeight(120)
    ApplyBackdrop(planABox, C_PLAN_BG, C_PLAN_BD)

    local planALbl = planABox:CreateFontString(nil, "OVERLAY")
    planALbl:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    planALbl:SetTextColor(C_SECTION_LBL[1], C_SECTION_LBL[2], C_SECTION_LBL[3])
    planALbl:SetPoint("TOPLEFT", planABox, "TOPLEFT", IPAD, -IPAD)
    planALbl:SetText("PLAN A")

    local planAText = planABox:CreateFontString(nil, "OVERLAY")
    planAText:SetFont("Fonts\\ARIALN.TTF", 13)
    planAText:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
    planAText:SetJustifyH("LEFT")
    planAText:SetJustifyV("TOP")
    planAText:SetNonSpaceWrap(true)
    planAText:SetWidth(COL_A_W - 2 * IPAD)
    planAText:SetPoint("TOPLEFT", planALbl, "BOTTOMLEFT", 0, -5)
    f.planABox  = planABox
    f.planAText = planAText

    -- ─── COLONNE DROITE : PLAN B + À ÉVITER ────────────────────────────────

    -- Plan B
    local planBBox = CreateFrame("Frame", nil, content, "BackdropTemplate")
    planBBox:SetWidth(COL_B_W)
    planBBox:SetHeight(80)
    ApplyBackdrop(planBBox, C_PLAN_BG, C_PLAN_BD)

    local planBLbl = planBBox:CreateFontString(nil, "OVERLAY")
    planBLbl:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    planBLbl:SetTextColor(C_BADGE_EPIC[1], C_BADGE_EPIC[2], C_BADGE_EPIC[3])
    planBLbl:SetPoint("TOPLEFT", planBBox, "TOPLEFT", IPAD, -IPAD)
    planBLbl:SetText("PLAN B")

    local planBText = planBBox:CreateFontString(nil, "OVERLAY")
    planBText:SetFont("Fonts\\ARIALN.TTF", 12)
    planBText:SetTextColor(C_BODY[1], C_BODY[2], C_BODY[3])
    planBText:SetJustifyH("LEFT")
    planBText:SetJustifyV("TOP")
    planBText:SetNonSpaceWrap(true)
    planBText:SetWidth(COL_B_W - 2 * IPAD)
    planBText:SetPoint("TOPLEFT", planBLbl, "BOTTOMLEFT", 0, -4)
    f.planBBox  = planBBox
    f.planBText = planBText

    -- A éviter
    local avoidBox = CreateFrame("Frame", nil, content, "BackdropTemplate")
    avoidBox:SetWidth(COL_B_W)
    avoidBox:SetHeight(70)
    ApplyBackdrop(avoidBox, C_AVOID_BG, C_AVOID_BD)

    local avoidLbl = avoidBox:CreateFontString(nil, "OVERLAY")
    avoidLbl:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    avoidLbl:SetTextColor(C_AVOID_LBL[1], C_AVOID_LBL[2], C_AVOID_LBL[3])
    avoidLbl:SetPoint("TOPLEFT", avoidBox, "TOPLEFT", IPAD, -IPAD)
    avoidLbl:SetText("A EVITER")

    local avoidText = avoidBox:CreateFontString(nil, "OVERLAY")
    avoidText:SetFont("Fonts\\ARIALN.TTF", 12)
    avoidText:SetTextColor(C_AVOID_TEXT[1], C_AVOID_TEXT[2], C_AVOID_TEXT[3])
    avoidText:SetJustifyH("LEFT")
    avoidText:SetJustifyV("TOP")
    avoidText:SetNonSpaceWrap(true)
    avoidText:SetWidth(COL_B_W - 2 * IPAD)
    avoidText:SetPoint("TOPLEFT", avoidLbl, "BOTTOMLEFT", 0, -4)
    f.avoidBox  = avoidBox
    f.avoidText = avoidText

    -- ─── RÔLES : Zone chips ─────────────────────────────────────────────────
    local rolesBox = CreateFrame("Frame", nil, content, "BackdropTemplate")
    rolesBox:SetWidth(CWIDTH)
    rolesBox:SetHeight(50)
    ApplyBackdrop(rolesBox, C_ROLES_BG, C_ROLES_BD)

    local rolesLbl = rolesBox:CreateFontString(nil, "OVERLAY")
    rolesLbl:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    rolesLbl:SetTextColor(C_SECTION_LBL[1], C_SECTION_LBL[2], C_SECTION_LBL[3])
    rolesLbl:SetPoint("TOPLEFT", rolesBox, "TOPLEFT", IPAD, -IPAD)
    rolesLbl:SetText("ROLES UTILES")
    f.rolesBox = rolesBox
    f.rolesLbl = rolesLbl

    -- Conteneur pour les chips (créées dynamiquement)
    f.chipContainer = rolesBox
    f.chips = {}

    -- ─── FOOTER ────────────────────────────────────────────────────────────
    local footer = f:CreateFontString(nil, "OVERLAY")
    footer:SetFont("Fonts\\ARIALN.TTF", 9)
    footer:SetTextColor(0.35, 0.38, 0.50)
    footer:SetPoint("BOTTOM", f, "BOTTOM", 0, 7)
    footer:SetText("Lecture visee : 10-15 secondes  -  Hierarchie visuelle pensee pour lecture en plein BG")
end

-- ─── Bouton langue FR/EN dans le header ────────────────────────────────────

function MBGA_BuildStratLangBtn(f, parent, lang, xOff, yOff)
    local btn = CreateFrame("Button", "MBGA_StratBtn_Lang" .. lang, parent, "BackdropTemplate")
    btn:SetSize(34, 24)
    btn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xOff, yOff)
    btn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 8,
        insets = { left=3, right=3, top=3, bottom=3 },
    })
    btn:SetBackdropColor(0.16, 0.17, 0.23, 1)
    btn:SetBackdropBorderColor(0.30, 0.32, 0.45, 1)
    local lbl = btn:CreateFontString(nil, "OVERLAY")
    lbl:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
    lbl:SetAllPoints()
    lbl:SetJustifyH("CENTER")
    lbl:SetJustifyV("MIDDLE")
    lbl:SetTextColor(0.78, 0.84, 1.00)
    lbl:SetText(lang)
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    btn:SetScript("OnClick", function()
        MBGA_SwitchLocale(lang)
        MBGA_UpdateStratLangUI()
        MBGA_UpdateStratContent()
        if MBGA_UpdateLangUI then MBGA_UpdateLangUI() end
    end)
    return btn
end

-- ─── Mise à jour visuelle des boutons FR/EN ────────────────────────────────

function MBGA_UpdateStratLangUI()
    local isFR = (MBGA_State.lang == "FR")
    local frBtn = _G["MBGA_StratBtn_LangFR"]
    local enBtn = _G["MBGA_StratBtn_LangEN"]
    if frBtn then
        if isFR then
            frBtn:SetBackdropColor(0.22, 0.28, 0.45, 1)
            frBtn:SetBackdropBorderColor(0.52, 0.72, 1.00, 1)
        else
            frBtn:SetBackdropColor(0.14, 0.15, 0.20, 1)
            frBtn:SetBackdropBorderColor(0.28, 0.30, 0.42, 1)
        end
    end
    if enBtn then
        if not isFR then
            enBtn:SetBackdropColor(0.22, 0.28, 0.45, 1)
            enBtn:SetBackdropBorderColor(0.52, 0.72, 1.00, 1)
        else
            enBtn:SetBackdropColor(0.14, 0.15, 0.20, 1)
            enBtn:SetBackdropBorderColor(0.28, 0.30, 0.42, 1)
        end
    end
end

-- ─── Mise à jour du contenu ─────────────────────────────────────────────────

function MBGA_UpdateStratContent()
    if not currentBGIndex or not MBGA_StratFrame then return end
    local bg = MBGA_BGs[currentBGIndex]
    if not bg then return end
    local f = MBGA_StratFrame

    -- Langue active
    local useLang = "fr"
    if bg.isEpic and MBGA_State.lang == "EN" and bg.strat.en then
        useLang = "en"
    end
    local strat = bg.strat[useLang]
    if not strat then return end

    -- Boutons FR/EN visibles seulement pour les BGs épiques
    local frBtn = _G["MBGA_StratBtn_LangFR"]
    local enBtn = _G["MBGA_StratBtn_LangEN"]
    if frBtn then frBtn:SetShown(bg.isEpic) end
    if enBtn then enBtn:SetShown(bg.isEpic) end

    -- Bouton Retour
    if f.backLabel then
        f.backLabel:SetText(useLang == "en" and "< Back" or "< Retour")
    end

    -- Bordure faction
    if MBGA_State.faction == "Horde" then
        f:SetBackdropBorderColor(0.55, 0.08, 0.08, 1)
    else
        f:SetBackdropBorderColor(0.07, 0.35, 0.72, 1)
    end

    -- Badge type
    if f.badge then
        if bg.isEpic then
            f.badge:SetText(useLang == "en" and "Epic BG  |  New" or "BG Epique")
            f.badge:SetTextColor(0.52, 0.72, 1.00)
        else
            f.badge:SetText(useLang == "en" and "Normal BG" or "BG Normal")
            f.badge:SetTextColor(0.99, 0.65, 0.10)
        end
    end

    -- Titre + format
    if f.bgTitle  then f.bgTitle:SetText(MBGA_L[bg.nameKey] or bg.id) end
    if f.bgFormat then f.bgFormat:SetText(bg.format or "") end

    -- Textes
    if f.objText  then f.objText:SetText(strat.objective or "")  end
    if f.planAText then f.planAText:SetText(strat.planA or "") end
    if f.planBText then f.planBText:SetText(strat.planB or "") end

    -- Avoid : convertit la table en liste à puces
    if f.avoidText then
        if strat.avoid and #strat.avoid > 0 then
            local lines = {}
            for _, v in ipairs(strat.avoid) do
                lines[#lines + 1] = "- " .. v
            end
            f.avoidText:SetText(table.concat(lines, "\n"))
            f.avoidBox:Show()
        else
            f.avoidText:SetText("")
            f.avoidBox:Hide()
        end
    end

    -- Chips de rôles
    MBGA_BuildRoleChips(strat.roles or {})

    -- Sync boutons FR/EN
    MBGA_UpdateStratLangUI()

    -- Layout dynamique
    MBGA_RelayoutStratContent()
end

-- ─── Chips de rôles ─────────────────────────────────────────────────────────
-- Créées/recréées à chaque changement de BG

function MBGA_BuildRoleChips(rolesTable)
    local f = MBGA_StratFrame
    if not f then return end

    -- Supprimer les anciens chips
    if f.chips then
        for _, chip in ipairs(f.chips) do
            chip:Hide()
            chip:SetParent(nil)
        end
    end
    f.chips = {}

    local box = f.rolesBox
    local chipH   = 20
    local chipPad = 6   -- padding interne horizontal
    local chipGap = 5   -- espace entre chips
    local rowGap  = 5   -- espace entre lignes
    local startX  = IPAD
    local startY  = -(IPAD + 16 + 6)  -- sous le label "ROLES UTILES"
    local x = startX
    local y = startY
    local maxX = CWIDTH - IPAD

    for _, role in ipairs(rolesTable) do
        -- Mesurer la largeur du texte (approximation : ~7px par char à taille 11)
        local textW = math.max(#role * 7, 30)
        local chipW = textW + chipPad * 2

        -- Retour à la ligne si nécessaire
        if x + chipW > maxX and x > startX then
            x = startX
            y = y - chipH - rowGap
        end

        local chip = CreateFrame("Frame", nil, box, "BackdropTemplate")
        chip:SetSize(chipW, chipH)
        chip:SetPoint("TOPLEFT", box, "TOPLEFT", x, y)
        chip:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 6,
            insets = { left=2, right=2, top=2, bottom=2 },
        })
        chip:SetBackdropColor(C_CHIP_BG[1], C_CHIP_BG[2], C_CHIP_BG[3], C_CHIP_BG[4])
        chip:SetBackdropBorderColor(C_CHIP_BD[1], C_CHIP_BD[2], C_CHIP_BD[3], C_CHIP_BD[4])

        local lbl = chip:CreateFontString(nil, "OVERLAY")
        lbl:SetFont("Fonts\\ARIALN.TTF", 11)
        lbl:SetTextColor(C_CHIP_TEXT[1], C_CHIP_TEXT[2], C_CHIP_TEXT[3])
        lbl:SetAllPoints()
        lbl:SetJustifyH("CENTER")
        lbl:SetJustifyV("MIDDLE")
        lbl:SetText(role)

        f.chips[#f.chips + 1] = chip
        x = x + chipW + chipGap
    end

    -- Hauteur du rolesBox en fonction du nombre de lignes utilisées
    local usedH = math.abs(y) + chipH + IPAD
    if #rolesTable == 0 then usedH = 0 end
    f.rolesBox.chipsHeight = usedH
end

-- ─── Layout dynamique ───────────────────────────────────────────────────────
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
end
