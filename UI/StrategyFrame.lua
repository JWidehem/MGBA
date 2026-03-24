-- UI/StrategyFrame.lua — Fiche stratégie redessinée
-- 5 boîtes colorées : OBJECTIF (or) → REGLE CRITIQUE (ambre) → COMPOSITION → PLAN A → PLAN B
-- Header intégré : [< Retour]   NOM DU BG   [FR] [EN]
-- Layout dynamique : chaque boîte est redimensionnée après SetText

local FRAME_W = 640
local FRAME_H = 570
local PAD     = 16   -- padding extérieur
local IPAD    = 10   -- padding interne des boîtes
local GAP     = 7    -- espace entre les boîtes

-- Largeur du contenu scrollable (frame - 2×PAD - scrollbar 22px)
local CWIDTH  = FRAME_W - 2 * PAD - 22

-- Index du BG actuellement affiché
local currentBGIndex = nil

-- ─── Configuration des 5 sections ────────────────────────────────────────────
-- lbl_fr / lbl_en : labels hardcodés sans emoji (polices WoW ne les supportent pas)
-- lsz / bsz : tailles label / corps   lc / bc : couleur label / corps
-- bg / bd : fond / bordure de la boîte

local SECTIONS = {
    {   -- 1. WIN CONDITION — or brillant, grande taille → impact immédiat
        key    = "win",
        lbl_fr = "OBJECTIF DE VICTOIRE",
        lbl_en = "WIN CONDITION",
        lsz    = 12,   bsz   = 14,
        lc     = { 1.00, 0.82, 0.00 },   -- or
        bc     = { 1.00, 1.00, 1.00 },   -- blanc
        bg     = { 0.10, 0.08, 0.02, 0.96 },
        bd     = { 0.72, 0.55, 0.07, 1.00 },
    },
    {   -- 2. REGLE CRITIQUE — ambre "danger", fond chaud → screams "attention"
        key    = "rule",
        lbl_fr = "REGLE CRITIQUE",
        lbl_en = "CRITICAL RULE",
        lsz    = 11,   bsz   = 12,
        lc     = { 1.00, 0.60, 0.00 },   -- ambre vif
        bc     = { 1.00, 0.85, 0.48 },   -- ambre clair
        bg     = { 0.16, 0.07, 0.01, 0.96 },
        bd     = { 0.92, 0.46, 0.00, 1.00 },
    },
    {   -- 3. COMPOSITION des rôles — neutre, compact, lisible
        key    = "roles",
        lbl_fr = "COMPOSITION",
        lbl_en = "COMPOSITION",
        lsz    = 11,   bsz   = 11,
        lc     = { 0.78, 0.78, 0.78 },
        bc     = { 0.94, 0.94, 0.94 },
        bg     = { 0.12, 0.12, 0.15, 0.90 },
        bd     = { 0.32, 0.32, 0.38, 1.00 },
    },
    {   -- 4. PLAN A — bleu ciel, positif, contenu principal
        key    = "planA",
        lbl_fr = "PLAN A",
        lbl_en = "PLAN A",
        lsz    = 11,   bsz   = 12,
        lc     = { 0.45, 0.78, 1.00 },
        bc     = { 0.90, 0.95, 1.00 },
        bg     = { 0.05, 0.10, 0.18, 0.92 },
        bd     = { 0.20, 0.48, 0.80, 1.00 },
    },
    {   -- 5. PLAN B — gris discret, secondaire, moins visible intentionnellement
        key    = "planB",
        lbl_fr = "PLAN B",
        lbl_en = "PLAN B",
        lsz    = 10,   bsz   = 11,
        lc     = { 0.52, 0.52, 0.56 },
        bc     = { 0.68, 0.68, 0.68 },
        bg     = { 0.10, 0.10, 0.12, 0.82 },
        bd     = { 0.26, 0.26, 0.30, 1.00 },
    },
}

-- ─── Ouverture de la fiche ────────────────────────────────────────────────────

function MBGA_OpenStrategyFrame(bgIndex)
    currentBGIndex = bgIndex
    if not MBGA_StratFrame then
        MBGA_BuildStratFrame()
    end
    -- Show() AVANT UpdateStratContent : GetStringHeight() retourne 0 sur frame cachée
    MBGA_StratFrame:Show()
    if MBGA_MainFrame then MBGA_MainFrame:Hide() end
    MBGA_UpdateStratContent()
end

-- ─── Construction de la frame (une seule fois) ───────────────────────────────

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
    f:SetBackdropColor(0.09, 0.09, 0.11, 0.97)

    -- ─── HEADER ──────────────────────────────────────────────────────────────

    -- Bouton Retour (gauche)
    local backBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
    backBtn:SetSize(92, 24)
    backBtn:SetPoint("TOPLEFT", f, "TOPLEFT", PAD, -12)
    backBtn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left=3, right=3, top=3, bottom=3 },
    })
    backBtn:SetBackdropColor(0.18, 0.18, 0.22, 0.95)
    local backLabel = backBtn:CreateFontString(nil, "OVERLAY")
    backLabel:SetFont("Fonts\\ARIALN.TTF", 12)
    backLabel:SetAllPoints()
    backLabel:SetJustifyH("CENTER")
    backLabel:SetJustifyV("MIDDLE")
    backLabel:SetTextColor(0.85, 0.85, 0.85)
    backLabel:SetText("< Retour")
    f.backLabel = backLabel
    backBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    backBtn:SetScript("OnClick", function()
        f:Hide()
        if MBGA_MainFrame then MBGA_MainFrame:Show() end
    end)

    -- Titre du BG (centré)
    local bgTitle = f:CreateFontString(nil, "OVERLAY")
    bgTitle:SetFont("Fonts\\FRIZQT__.TTF", 17, "OUTLINE")
    bgTitle:SetPoint("TOP", f, "TOP", 0, -14)
    bgTitle:SetTextColor(1, 0.82, 0)
    f.bgTitle = bgTitle

    -- Boutons FR / EN (droite) — pour switcher la langue depuis la fiche
    MBGA_BuildStratLangBtn(f, "FR", -(PAD + 40), -12)
    MBGA_BuildStratLangBtn(f, "EN", -PAD,         -12)

    -- Ligne de séparation header / contenu
    local sep = f:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(0.4, 0.4, 0.4, 0.5)
    sep:SetSize(FRAME_W - 2 * PAD, 1)
    sep:SetPoint("TOP", f, "TOP", 0, -44)

    -- ─── ScrollFrame ─────────────────────────────────────────────────────────
    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",     f, "TOPLEFT",     PAD,        -50)
    scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -(PAD + 20), PAD)

    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(CWIDTH)
    content:SetHeight(800)  -- redimensionné dynamiquement
    scroll:SetScrollChild(content)
    f.scrollContent = content

    -- ─── Boîtes de sections ───────────────────────────────────────────────────
    -- Chaque section = 1 Frame avec backdrop + 1 label FontString + 1 body FontString
    f.sectionBoxes = {}
    for _, sec in ipairs(SECTIONS) do
        local box = CreateFrame("Frame", nil, content, "BackdropTemplate")
        box:SetWidth(CWIDTH)
        box:SetHeight(60)  -- hauteur ajustée dynamiquement
        box:SetBackdrop({
            bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 8,
            insets = { left=4, right=4, top=4, bottom=4 },
        })
        box:SetBackdropColor(sec.bg[1], sec.bg[2], sec.bg[3], sec.bg[4])
        box:SetBackdropBorderColor(sec.bd[1], sec.bd[2], sec.bd[3], sec.bd[4])

        -- Label de section (FRIZQT = fonte WoW emblématique, meilleure lisibilité titre)
        local lbl = box:CreateFontString(nil, "OVERLAY")
        lbl:SetFont("Fonts\\FRIZQT__.TTF", sec.lsz, "OUTLINE")
        lbl:SetTextColor(sec.lc[1], sec.lc[2], sec.lc[3])
        lbl:SetJustifyH("LEFT")
        lbl:SetWidth(CWIDTH - 2 * IPAD)
        lbl:SetPoint("TOPLEFT", box, "TOPLEFT", IPAD, -IPAD)

        -- Corps de texte (ARIALN = meilleure lisibilité corps de texte)
        local body = box:CreateFontString(nil, "OVERLAY")
        body:SetFont("Fonts\\ARIALN.TTF", sec.bsz)
        body:SetTextColor(sec.bc[1], sec.bc[2], sec.bc[3])
        body:SetJustifyH("LEFT")
        body:SetJustifyV("TOP")
        body:SetNonSpaceWrap(true)
        body:SetWidth(CWIDTH - 2 * IPAD)
        body:SetPoint("TOPLEFT", lbl, "BOTTOMLEFT", 0, -5)

        f.sectionBoxes[sec.key] = { box = box, lbl = lbl, body = body, cfg = sec }
    end
end

-- ─── Bouton langue FR/EN intégré à la StratFrame ─────────────────────────────

function MBGA_BuildStratLangBtn(parent, lang, xOff, yOff)
    local btn = CreateFrame("Button", "MBGA_StratBtn_Lang" .. lang, parent, "BackdropTemplate")
    btn:SetSize(34, 24)
    btn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xOff, yOff)
    btn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left=3, right=3, top=3, bottom=3 },
    })
    local lbl = btn:CreateFontString(nil, "OVERLAY")
    lbl:SetFont("Fonts\\ARIALN.TTF", 13, "OUTLINE")
    lbl:SetAllPoints()
    lbl:SetJustifyH("CENTER")
    lbl:SetJustifyV("MIDDLE")
    lbl:SetTextColor(1, 1, 1)
    lbl:SetText(lang)
    btn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    btn:SetScript("OnClick", function()
        MBGA_SwitchLocale(lang)
        MBGA_UpdateStratLangUI()
        MBGA_UpdateStratContent()
        -- Sync les boutons FR/EN de la MainFrame aussi
        if MBGA_UpdateLangUI then MBGA_UpdateLangUI() end
    end)
    return btn
end

-- ─── Mise à jour visuelle des boutons FR/EN (StratFrame) ─────────────────────

function MBGA_UpdateStratLangUI()
    local isFR = (MBGA_State.lang == "FR")
    local frBtn = _G["MBGA_StratBtn_LangFR"]
    local enBtn = _G["MBGA_StratBtn_LangEN"]
    if frBtn then
        local v = isFR and 0.30 or 0.10
        frBtn:SetBackdropColor(v, v, v, 0.90)
    end
    if enBtn then
        local v = isFR and 0.10 or 0.30
        enBtn:SetBackdropColor(v, v, v, 0.90)
    end
end

-- ─── Mise à jour du contenu ──────────────────────────────────────────────────

function MBGA_UpdateStratContent()
    if not currentBGIndex or not MBGA_StratFrame then return end
    local bg = MBGA_BGs[currentBGIndex]
    if not bg then return end

    -- Langue : BGs épiques supportent FR+EN, BGs normaux = FR uniquement (par design)
    local useLang = "fr"
    if bg.isEpic and MBGA_State.lang == "EN" and bg.strat.en then
        useLang = "en"
    end
    local strat = bg.strat[useLang]
    if not strat then return end

    -- Titre du BG (nom dans la langue active)
    MBGA_StratFrame.bgTitle:SetText(MBGA_L[bg.nameKey] or bg.id)

    -- Bouton Retour bilingue
    if MBGA_StratFrame.backLabel then
        MBGA_StratFrame.backLabel:SetText(useLang == "en" and "< Back" or "< Retour")
    end

    -- Bordure faction
    if MBGA_State.faction == "Horde" then
        MBGA_StratFrame:SetBackdropBorderColor(0.55, 0, 0, 1)
    else
        MBGA_StratFrame:SetBackdropBorderColor(0, 0.44, 0.87, 1)
    end

    -- Contenu des sections
    local textMap = {
        win   = strat.winCondition or "",
        rule  = strat.criticalRule or "",
        roles = strat.roles        or "",
        planA = strat.planA        or "",
        planB = strat.planB        or "",
    }

    for _, sec in ipairs(SECTIONS) do
        local refs = MBGA_StratFrame.sectionBoxes[sec.key]
        if refs then
            -- Label bilingue depuis la config de section (pas de clé locale → pas d'emoji)
            refs.lbl:SetText(useLang == "en" and sec.lbl_en or sec.lbl_fr)
            refs.body:SetText(textMap[sec.key])
        end
    end

    -- Sync boutons FR/EN
    MBGA_UpdateStratLangUI()

    -- Layout dynamique
    MBGA_RelayoutStratContent()
end

-- ─── Layout dynamique ────────────────────────────────────────────────────────
-- Chaque boîte est positionnée et redimensionnée selon la hauteur mesurée du texte.
-- Les GetStringHeight() sont fiables car StratFrame est déjà Show() à ce stade.

function MBGA_RelayoutStratContent()
    if not MBGA_StratFrame then return end
    local content = MBGA_StratFrame.scrollContent
    if not content then return end

    local yOff = 0  -- curseur vertical (valeurs négatives vers le bas)

    for _, sec in ipairs(SECTIONS) do
        local refs = MBGA_StratFrame.sectionBoxes[sec.key]
        if refs then
            local bodyText = refs.body:GetText() or ""
            if bodyText == "" then
                refs.box:Hide()
            else
                refs.box:Show()
                -- Positionner la boîte
                refs.box:ClearAllPoints()
                refs.box:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOff)

                -- Mesurer les hauteurs (valables car frame visible + texte défini)
                local lblH  = refs.lbl:GetStringHeight()
                local bodyH = refs.body:GetStringHeight()
                if lblH  < sec.lsz then lblH  = sec.lsz  end
                if bodyH < sec.bsz then bodyH = sec.bsz  end

                -- Redimensionner la boîte : padding haut + label + gap + corps + padding bas
                local boxH = IPAD + lblH + 5 + bodyH + IPAD
                refs.box:SetHeight(boxH)

                yOff = yOff - boxH - GAP
            end
        end
    end

    -- Hauteur totale du contenu scrollable
    content:SetHeight(math.max(math.abs(yOff) + PAD, 60))
end
