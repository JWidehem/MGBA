-- UI/StrategyFrame.lua — Fiche stratégie d'un BG
-- Affiche : Win Condition → Règle Critique → Rôles → Plan A → Plan B
-- Hiérarchie visuelle : taille + contraste + couleur sémantique
-- Layout dynamique : ClearAllPoints + SetPoint repositionne tout après SetText

local FRAME_W = 600
local FRAME_H = 540
local PADDING = 16
local SEC_GAP = 14  -- espace entre les sections

-- Index du BG actuellement affiché
local currentBGIndex = nil

-- Table des sections dans l'ordre d'affichage
local SECTIONS = {
    { key = "win",   labelKey = "SECTION_WIN",    color = { r=1, g=0.84, b=0 },       labelSize = 13, bodySize = 14 },
    { key = "rule",  labelKey = "SECTION_RULE",   color = { r=1, g=0.65, b=0 },       labelSize = 11, bodySize = 12 },
    { key = "roles", labelKey = "SECTION_ROLES",  color = { r=0.85, g=0.85, b=0.85 }, labelSize = 11, bodySize = 11 },
    { key = "planA", labelKey = "SECTION_PLAN_A", color = { r=0.55, g=0.85, b=1 },    labelSize = 11, bodySize = 12 },
    { key = "planB", labelKey = "SECTION_PLAN_B", color = { r=0.65, g=0.65, b=0.65 }, labelSize = 11, bodySize = 11 },
}

-- ─── Ouverture de la fiche ────────────────────────────────────────────────────

function MBGA_OpenStrategyFrame(bgIndex)
    currentBGIndex = bgIndex

    if not MBGA_StratFrame then
        MBGA_BuildStratFrame()
    end

    -- Show() EN PREMIER : GetStringHeight() retourne 0 sur une frame cachée
    MBGA_StratFrame:Show()
    if MBGA_MainFrame then
        MBGA_MainFrame:Hide()
    end

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
    f:SetBackdropColor(0.10, 0.10, 0.12, 0.97)

    -- ─── Bouton Retour ───────────────────────────────────────────────────────
    local backBtn = CreateFrame("Button", nil, f, "BackdropTemplate")
    backBtn:SetSize(80, 22)
    backBtn:SetPoint("TOPLEFT", f, "TOPLEFT", PADDING, -14)
    backBtn:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 10,
        insets = { left=3, right=3, top=3, bottom=3 },
    })
    backBtn:SetBackdropColor(0.2, 0.2, 0.2, 0.9)
    local backLabel = backBtn:CreateFontString(nil, "OVERLAY")
    backLabel:SetFont("Fonts\\ARIALN.TTF", 11)
    backLabel:SetAllPoints()
    backLabel:SetJustifyH("CENTER")
    backLabel:SetJustifyV("MIDDLE")
    backLabel:SetTextColor(0.9, 0.9, 0.9)
    backLabel:SetText(MBGA_L["BTN_BACK"])
    backBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    backBtn:SetScript("OnClick", function()
        f:Hide()
        if MBGA_MainFrame then MBGA_MainFrame:Show() end
    end)

    -- ─── Titre du BG ─────────────────────────────────────────────────────────
    local bgTitle = f:CreateFontString(nil, "OVERLAY")
    bgTitle:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    bgTitle:SetPoint("TOP", f, "TOP", 0, -16)
    bgTitle:SetTextColor(1, 0.82, 0)
    f.bgTitle = bgTitle

    -- ─── Séparateur header ───────────────────────────────────────────────────
    local sep = f:CreateTexture(nil, "ARTWORK")
    sep:SetColorTexture(0.4, 0.4, 0.4, 0.5)
    sep:SetSize(FRAME_W - 32, 1)
    sep:SetPoint("TOP", f, "TOP", 0, -44)

    -- ─── ScrollFrame ─────────────────────────────────────────────────────────
    local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT",     f, "TOPLEFT",      PADDING,         -50)
    scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT",  -(PADDING + 22),  PADDING)

    local contentW = FRAME_W - PADDING * 2 - 28
    local content  = CreateFrame("Frame", nil, scroll)
    content:SetWidth(contentW)
    content:SetHeight(600)  -- ajusté dynamiquement dans RelayoutStratContent
    scroll:SetScrollChild(content)
    f.scrollContent = content

    -- ─── Création des FontStrings pour chaque section ────────────────────────
    -- On crée labels + bodies ici et on les stocke sur la frame.
    -- Le layout (positions) est géré dans MBGA_RelayoutStratContent.
    f.sections = {}
    for _, sec in ipairs(SECTIONS) do
        local lbl = content:CreateFontString(nil, "OVERLAY")
        lbl:SetFont("Fonts\\FRIZQT__.TTF", sec.labelSize, "OUTLINE")
        lbl:SetTextColor(sec.color.r, sec.color.g, sec.color.b)
        lbl:SetJustifyH("LEFT")
        lbl:SetWidth(contentW)

        local body = content:CreateFontString(nil, "OVERLAY")
        body:SetFont("Fonts\\ARIALN.TTF", sec.bodySize)
        body:SetTextColor(1, 1, 1)
        body:SetJustifyH("LEFT")
        body:SetJustifyV("TOP")
        body:SetNonSpaceWrap(true)
        body:SetWidth(contentW - 8)

        f.sections[sec.key] = { lbl = lbl, body = body }
    end
end

-- ─── Mise à jour du contenu et relayout ──────────────────────────────────────

function MBGA_UpdateStratContent()
    if not currentBGIndex then return end
    local bg = MBGA_BGs[currentBGIndex]
    if not bg or not MBGA_StratFrame then return end

    -- Détermine la langue : épiques supportent EN, normaux = toujours FR
    local lang = "fr"
    if bg.isEpic and MBGA_State.lang == "EN" and bg.strat.en then
        lang = "en"
    end
    local strat = bg.strat[lang]
    if not strat then return end

    -- Titre du BG
    MBGA_StratFrame.bgTitle:SetText(MBGA_L[bg.nameKey] or bg.id)

    -- Couleur de bordure selon faction
    if MBGA_State.faction == "Horde" then
        MBGA_StratFrame:SetBackdropBorderColor(0.55, 0, 0, 1)
    else
        MBGA_StratFrame:SetBackdropBorderColor(0, 0.44, 0.87, 1)
    end

    -- Mapping clé de section → champ de la strat
    local textMap = {
        win   = strat.winCondition or "",
        rule  = strat.criticalRule or "",
        roles = strat.roles or "",
        planA = strat.planA or "",
        planB = strat.planB or "",
    }

    -- Textes des labels traduits + corps de texte
    for _, sec in ipairs(SECTIONS) do
        local refs = MBGA_StratFrame.sections[sec.key]
        if refs then
            refs.lbl:SetText(MBGA_L[sec.labelKey] or sec.labelKey)
            refs.body:SetText(textMap[sec.key])
        end
    end

    -- Relayout dynamique après SetText (heights connues seulement après SetText)
    MBGA_RelayoutStratContent()
end

-- ─── Layout dynamique ────────────────────────────────────────────────────────
-- ClearAllPoints + SetPoint est possible sur les FontStrings en WoW.
-- Après SetText, GetStringHeight() retourne la vraie hauteur wrappée.

function MBGA_RelayoutStratContent()
    if not MBGA_StratFrame then return end
    local content = MBGA_StratFrame.scrollContent
    if not content then return end

    local yOff = 0

    for _, sec in ipairs(SECTIONS) do
        local refs = MBGA_StratFrame.sections[sec.key]
        if refs then
            -- Label de section
            refs.lbl:ClearAllPoints()
            refs.lbl:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOff)
            local lblH = refs.lbl:GetStringHeight()
            if lblH < sec.labelSize then lblH = sec.labelSize end
            yOff = yOff - lblH - 4

            -- Corps de texte
            refs.body:ClearAllPoints()
            refs.body:SetPoint("TOPLEFT", content, "TOPLEFT", 6, yOff)
            local bodyH = refs.body:GetStringHeight()
            if bodyH < sec.bodySize then bodyH = sec.bodySize end
            yOff = yOff - bodyH - SEC_GAP
        end
    end

    -- Ajuste la hauteur du contenu scrollable
    content:SetHeight(math.abs(yOff) + 16)
end
