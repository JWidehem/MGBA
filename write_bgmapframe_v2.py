#!/usr/bin/env python3
# write_bgmapframe_v2.py — Génère UI/BGMapFrame.lua (layout v2 avec 2 onglets)

lua = r"""-- UI/BGMapFrame.lua — Interface carte interactive MDT-style (v2)
-- Layout : header + bandeau nom BG + carte (gauche) + panneau 2 onglets (droite)
--
-- Onglet STRAT  : Objectif principal | Etapes numérotées | Plan B | Erreur
-- Onglet ROLES  : Rôles/classes recommandés | Meilleure comp (Phase 2)
--
-- Données : BGMapData (carte) + StrategyData (textes objectif/planB/avoid/roles)

-- ─── Constantes ───────────────────────────────────────────────────────────────
local FRAME_W     = 1000
local FRAME_H     = 660
local HDR_H       = 44        -- header principal
local BGNAME_H    = 26        -- bandeau nom du BG
local PAD         = 10        -- padding global
local MAP_W       = 760       -- largeur zone carte
-- MAP_H = tout l'espace vertical disponible sous le bandeau nom
-- = FRAME_H - PAD(top) - HDR_H - BGNAME_H - gap(8) - PAD(bottom)
local MAP_H       = FRAME_H - PAD - HDR_H - BGNAME_H - 8 - PAD   -- 562

local TILE_COLS   = 4
local TILE_ROWS   = 3
local TILE_W_BASE = MAP_W / TILE_COLS  -- 190 px
local TILE_H_BASE = TILE_W_BASE
local TILE_GRID_H = TILE_H_BASE * TILE_ROWS  -- 570 px

local SCALE_MIN   = 0.5
local SCALE_MAX   = 3.0
local SCALE_STEP  = 0.18

local NODE_SIZE   = 30
local RING_SIZE   = 50

-- ─── Couleurs ─────────────────────────────────────────────────────────────────
local C_BG       = {0.07, 0.07, 0.09, 0.97}
local C_HDR      = {0.10, 0.12, 0.16, 1.00}
local C_PANEL    = {0.09, 0.09, 0.12, 0.97}
local C_TITLE    = {1.00, 0.82, 0.00, 1}
local C_BGNAME   = {0.07, 0.07, 0.11, 0.97}
local C_STEP_ON  = {0.22, 0.17, 0.04, 0.97}   -- etape active (fond doré)
local C_STEP_OFF = {0.12, 0.12, 0.16, 0.95}   -- etape inactive
local C_PLANB    = {0.16, 0.08, 0.02, 0.97}   -- fond Plan B orange foncé
local C_PLANB_ON = {0.28, 0.14, 0.02, 0.97}   -- fond Plan B actif
local C_AVOID    = {0.16, 0.04, 0.04, 0.97}   -- fond Erreur rouge foncé
local C_AVOID_ON = {0.28, 0.06, 0.06, 0.97}   -- fond Erreur actif
local C_TAB_ON   = {0.17, 0.14, 0.05, 0.97}   -- onglet actif (doré sombre)
local C_TAB_OFF  = {0.10, 0.10, 0.13, 0.97}   -- onglet inactif
local C_OBJ      = {0.07, 0.07, 0.11, 0.97}   -- fond carte objectif
local C_ROLES_A  = {0.08, 0.08, 0.14, 0.97}   -- fond carte roles
local C_ROLES_B  = {0.06, 0.10, 0.06, 0.97}   -- fond carte comp (vert très sombre)

-- ─── État interne ─────────────────────────────────────────────────────────────
local currentBGIndex = nil
local currentStep    = 1
local mapScale       = 1.0
local activeTab      = "strat"  -- "strat" | "roles"
-- "sel" = dernière sélection : "step"/"planb"/"avoid" pour la descBox
local lastSel        = "none"

local nodeBlips    = {}   -- [nodeId] = Button
local overlayLines = {}   -- pool de Line objects
local stepButtons  = {}   -- boutons d'etapes dans l'onglet Strat

local panState = {
    active=false, startX=0, startY=0, initPanX=0, initPanY=0, panX=0, panY=0
}

-- ─── Helpers backdrop standard ────────────────────────────────────────────────
local function BD_TILE(size, edge)
    return {
        bgFile  = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile= "Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, tileSize=size, edgeSize=edge,
        insets={left=3, right=3, top=3, bottom=3},
    }
end

-- ─────────────────────────────────────────────────────────────────────────────
-- ENTRÉE PUBLIQUE
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_OpenBGMapFrame(bgIndex)
    currentBGIndex = bgIndex
    currentStep    = 1
    mapScale       = 1.0
    activeTab      = "strat"
    lastSel        = "none"

    if not MBGA_BGMapFrame then MBGA_BuildBGMapFrame() end

    if MBGA_MainFrame and MBGA_MainFrame:IsShown() then
        MBGA_MainFrame:Hide()
    end

    MBGA_UpdateBGMapContent()
    MBGA_BGMapFrame:Show()
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CONSTRUCTION (lazy — une seule fois)
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_BuildBGMapFrame()

    -- ── Outer frame ──────────────────────────────────────────────────────────
    local f = CreateFrame("Frame", "MBGA_BGMapFrame", UIParent, "BackdropTemplate")
    f:SetSize(FRAME_W, FRAME_H)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop",  f.StopMovingOrSizing)
    f:SetFrameStrata("HIGH")
    f:SetClampedToScreen(true)
    f:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile=true, tileSize=32, edgeSize=26,
        insets={left=9, right=9, top=9, bottom=9},
    })
    f:SetBackdropColor(C_BG[1], C_BG[2], C_BG[3], C_BG[4])

    -- ── Header ───────────────────────────────────────────────────────────────
    local hdr = CreateFrame("Frame", nil, f, "BackdropTemplate")
    hdr:SetPoint("TOPLEFT",  f, "TOPLEFT",  PAD, -PAD)
    hdr:SetPoint("TOPRIGHT", f, "TOPRIGHT", -PAD, -PAD)
    hdr:SetHeight(HDR_H)
    hdr:SetBackdrop(BD_TILE(16, 10))
    hdr:SetBackdropColor(C_HDR[1], C_HDR[2], C_HDR[3], C_HDR[4])

    -- Bouton <- Retour (gauche)
    local backBtn = CreateFrame("Button", nil, hdr, "BackdropTemplate")
    backBtn:SetSize(80, 28)
    backBtn:SetPoint("LEFT", hdr, "LEFT", 8, 0)
    backBtn:SetBackdrop(BD_TILE(16, 10))
    backBtn:SetBackdropColor(0.14, 0.14, 0.18, 0.95)
    backBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    local backLbl = backBtn:CreateFontString(nil, "OVERLAY")
    backLbl:SetFont("Fonts\\ARIALN.TTF", 13, "OUTLINE")
    backLbl:SetAllPoints()
    backLbl:SetJustifyH("CENTER")
    backLbl:SetText("<- Retour")
    backLbl:SetTextColor(0.80, 0.80, 0.85)
    backBtn:SetScript("OnClick", function()
        MBGA_BGMapFrame:Hide()
        if MBGA_MainFrame then MBGA_MainFrame:Show() end
    end)

    -- Titre "Make BG's Great Again" (centré)
    local mainTitle = hdr:CreateFontString(nil, "OVERLAY")
    mainTitle:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    mainTitle:SetPoint("CENTER", hdr, "CENTER", 0, 0)
    mainTitle:SetTextColor(C_TITLE[1], C_TITLE[2], C_TITLE[3])
    mainTitle:SetText("Make BG's Great Again")

    -- Bouton fermer x (extreme droite)
    local closeBtn = CreateFrame("Button", nil, hdr, "UIPanelCloseButton")
    closeBtn:SetPoint("RIGHT", hdr, "RIGHT", -2, 0)
    f.closeBtn = closeBtn

    -- Bouton Alliance (à gauche du x)
    local alliBtn = CreateFrame("Button", "MBGA_Map_AlliBtn", hdr, "BackdropTemplate")
    alliBtn:SetSize(80, 28)
    alliBtn:SetPoint("RIGHT", closeBtn, "LEFT", -4, 0)
    alliBtn:SetBackdrop(BD_TILE(16, 10))
    alliBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    local alliLbl = alliBtn:CreateFontString(nil, "OVERLAY")
    alliLbl:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    alliLbl:SetAllPoints()
    alliLbl:SetJustifyH("CENTER")
    alliLbl:SetJustifyV("MIDDLE")
    alliLbl:SetText("Alliance")
    alliLbl:SetTextColor(0.35, 0.65, 1)
    alliBtn:SetScript("OnClick", function()
        MBGA_State.faction = "Alliance"
        MBGA_UpdateFactionUI()
        MBGA_UpdateMapFactionUI()
    end)
    f.mapAlliBtn = alliBtn

    -- Bouton Horde (à gauche de Alliance)
    local hordeBtn = CreateFrame("Button", "MBGA_Map_HordeBtn", hdr, "BackdropTemplate")
    hordeBtn:SetSize(80, 28)
    hordeBtn:SetPoint("RIGHT", alliBtn, "LEFT", -4, 0)
    hordeBtn:SetBackdrop(BD_TILE(16, 10))
    hordeBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    local hordeLbl = hordeBtn:CreateFontString(nil, "OVERLAY")
    hordeLbl:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    hordeLbl:SetAllPoints()
    hordeLbl:SetJustifyH("CENTER")
    hordeLbl:SetJustifyV("MIDDLE")
    hordeLbl:SetText("Horde")
    hordeLbl:SetTextColor(1, 0.35, 0.35)
    hordeBtn:SetScript("OnClick", function()
        MBGA_State.faction = "Horde"
        MBGA_UpdateFactionUI()
        MBGA_UpdateMapFactionUI()
    end)
    f.mapHordeBtn = hordeBtn

    -- ── Bandeau nom du BG ─────────────────────────────────────────────────────
    local bgNameBar = CreateFrame("Frame", nil, f, "BackdropTemplate")
    bgNameBar:SetPoint("TOPLEFT",  f, "TOPLEFT",  PAD, -(PAD + HDR_H + 4))
    bgNameBar:SetPoint("TOPRIGHT", f, "TOPRIGHT", -PAD, -(PAD + HDR_H + 4))
    bgNameBar:SetHeight(BGNAME_H)
    bgNameBar:SetBackdrop(BD_TILE(16, 10))
    bgNameBar:SetBackdropColor(C_BGNAME[1], C_BGNAME[2], C_BGNAME[3], C_BGNAME[4])

    local bgNameLbl = bgNameBar:CreateFontString(nil, "OVERLAY")
    bgNameLbl:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
    bgNameLbl:SetAllPoints()
    bgNameLbl:SetJustifyH("CENTER")
    bgNameLbl:SetJustifyV("MIDDLE")
    bgNameLbl:SetTextColor(1, 0.90, 0.50)
    bgNameLbl:SetText("")
    f.bgNameLbl = bgNameLbl

    -- ── Zone de carte ─────────────────────────────────────────────────────────
    -- mapTopY = décalage depuis le haut de f (sous bandeau nom + gap)
    local mapTopY = -(PAD + HDR_H + BGNAME_H + 8)

    local clipFrame = CreateFrame("Frame", "MBGA_MapClip", f)
    clipFrame:SetPoint("TOPLEFT",    f, "TOPLEFT",    PAD, mapTopY)
    clipFrame:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", PAD, PAD)
    clipFrame:SetWidth(MAP_W)
    clipFrame:SetClipsChildren(true)
    f.clipFrame = clipFrame

    local mapBg = clipFrame:CreateTexture(nil, "BACKGROUND")
    mapBg:SetAllPoints()
    mapBg:SetColorTexture(0.06, 0.07, 0.10, 1)

    local mapPanel = CreateFrame("Frame", "MBGA_MapPanel", clipFrame)
    mapPanel:SetSize(MAP_W, TILE_GRID_H)
    mapPanel:SetPoint("TOPLEFT")
    mapPanel:EnableMouse(false)
    f.mapPanel = mapPanel

    -- 12 tiles en grille 4x3
    for row = 0, TILE_ROWS - 1 do
        for col = 0, TILE_COLS - 1 do
            local idx  = row * TILE_COLS + col + 1
            local tile = mapPanel:CreateTexture("MBGA_Tile" .. idx, "BACKGROUND", nil, -2)
            tile:SetSize(TILE_W_BASE, TILE_H_BASE)
            tile:SetPoint("TOPLEFT", mapPanel, "TOPLEFT", col * TILE_W_BASE, -row * TILE_H_BASE)
            mapPanel["tile" .. idx] = tile
        end
    end
    f.tile1 = mapPanel.tile1

    -- Pan via clic-glisser
    clipFrame:EnableMouse(true)
    clipFrame:SetScript("OnMouseDown", function(self, btn)
        if btn == "LeftButton" then
            panState.active = true
            panState.startX, panState.startY = GetCursorPosition()
            panState.initPanX = panState.panX
            panState.initPanY = panState.panY
        end
    end)
    clipFrame:SetScript("OnMouseUp", function(self, btn)
        if btn == "LeftButton" then panState.active = false end
    end)
    clipFrame:SetScript("OnUpdate", function(self)
        if not panState.active then return end
        local cx, cy  = GetCursorPosition()
        local scl     = UIParent:GetEffectiveScale()
        local mp      = MBGA_BGMapFrame.mapPanel
        local maxX    = math.max(0, mp:GetWidth()  - self:GetWidth())
        local maxY    = math.max(0, mp:GetHeight() - self:GetHeight())
        panState.panX = math.min(0, math.max(-maxX,
                            panState.initPanX + (cx - panState.startX) / scl))
        panState.panY = math.min(0, math.max(-maxY,
                            panState.initPanY + (cy - panState.startY) / scl))
        mp:ClearAllPoints()
        mp:SetPoint("TOPLEFT", self, "TOPLEFT", panState.panX, panState.panY)
    end)

    -- Zoom molette
    clipFrame:EnableMouseWheel(true)
    clipFrame:SetScript("OnMouseWheel", function(self, delta)
        local ns = math.max(SCALE_MIN, math.min(SCALE_MAX, mapScale + delta * SCALE_STEP))
        if ns ~= mapScale then mapScale = ns; MBGA_ApplyMapScale() end
    end)

    -- Hint zoom/pan (bas gauche de la carte)
    local zoomHint = f:CreateFontString(nil, "OVERLAY")
    zoomHint:SetFont("Fonts\\ARIALN.TTF", 9)
    zoomHint:SetPoint("BOTTOMLEFT", clipFrame, "BOTTOMLEFT", 4, 3)
    zoomHint:SetTextColor(0.28, 0.28, 0.32)
    zoomHint:SetText("Molette = zoom  |  Clic-glisser = deplacer")

    -- ── Panneau droit ─────────────────────────────────────────────────────────
    local panel = CreateFrame("Frame", "MBGA_RightPanel", f, "BackdropTemplate")
    panel:SetPoint("TOPLEFT",     clipFrame, "TOPRIGHT", 8, 0)
    panel:SetPoint("BOTTOMRIGHT", f,         "BOTTOMRIGHT", -PAD, PAD)
    panel:SetBackdrop({
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, tileSize=16, edgeSize=10,
        insets={left=3, right=3, top=3, bottom=3},
    })
    panel:SetBackdropColor(C_PANEL[1], C_PANEL[2], C_PANEL[3], C_PANEL[4])
    f.rightPanel = panel

    -- ── Barre d'onglets ───────────────────────────────────────────────────────
    local TAB_H     = 26
    local TAB_PAD_Y = -5    -- décalage depuis le haut du panel

    local tabStrat = CreateFrame("Button", nil, panel, "BackdropTemplate")
    tabStrat:SetSize(99, TAB_H)
    tabStrat:SetPoint("TOPLEFT", panel, "TOPLEFT", 5, TAB_PAD_Y)
    tabStrat:SetBackdrop(BD_TILE(16, 10))
    tabStrat:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    local tabStratLbl = tabStrat:CreateFontString(nil, "OVERLAY")
    tabStratLbl:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE")
    tabStratLbl:SetAllPoints()
    tabStratLbl:SetJustifyH("CENTER")
    tabStratLbl:SetJustifyV("MIDDLE")
    tabStratLbl:SetText("STRAT")
    tabStrat.lbl = tabStratLbl
    f.tabStrat = tabStrat

    local tabRoles = CreateFrame("Button", nil, panel, "BackdropTemplate")
    tabRoles:SetSize(99, TAB_H)
    tabRoles:SetPoint("LEFT", tabStrat, "RIGHT", 4, 0)
    tabRoles:SetBackdrop(BD_TILE(16, 10))
    tabRoles:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    local tabRolesLbl = tabRoles:CreateFontString(nil, "OVERLAY")
    tabRolesLbl:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE")
    tabRolesLbl:SetAllPoints()
    tabRolesLbl:SetJustifyH("CENTER")
    tabRolesLbl:SetJustifyV("MIDDLE")
    tabRolesLbl:SetText("ROLES")
    tabRoles.lbl = tabRolesLbl
    f.tabRoles = tabRoles

    tabStrat:SetScript("OnClick", function() MBGA_SwitchPanelTab("strat") end)
    tabRoles:SetScript("OnClick", function() MBGA_SwitchPanelTab("roles") end)

    -- ── Contenu onglet STRAT ──────────────────────────────────────────────────
    -- Zone de contenu : sous la barre d'onglets, sur toute la hauteur du panneau
    local CTOP = -(5 + TAB_H + 5)   -- y offset depuis panel TOP

    local stratContent = CreateFrame("Frame", nil, panel)
    stratContent:SetPoint("TOPLEFT",     panel, "TOPLEFT",     4, CTOP)
    stratContent:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -4, 4)
    f.stratContent = stratContent

    -- Description (bas de l'onglet strat, toujours visible)
    local descBox = CreateFrame("Frame", nil, stratContent, "BackdropTemplate")
    descBox:SetPoint("BOTTOMLEFT",  stratContent, "BOTTOMLEFT",  0, 0)
    descBox:SetPoint("BOTTOMRIGHT", stratContent, "BOTTOMRIGHT", 0, 0)
    descBox:SetHeight(82)
    descBox:SetBackdrop(BD_TILE(16, 10))
    descBox:SetBackdropColor(0.05, 0.05, 0.08, 0.97)
    f.descBox = descBox

    local descText = descBox:CreateFontString(nil, "OVERLAY")
    descText:SetFont("Fonts\\ARIALN.TTF", 10)
    descText:SetPoint("TOPLEFT",  descBox, "TOPLEFT",  6, -6)
    descText:SetPoint("TOPRIGHT", descBox, "TOPRIGHT", -6, -6)
    descText:SetHeight(70)
    descText:SetJustifyH("LEFT")
    descText:SetJustifyV("TOP")
    descText:SetTextColor(0.78, 0.78, 0.83)
    descText:SetWordWrap(true)
    descText:SetNonSpaceWrap(false)
    f.descText = descText

    -- Bouton ERREUR à ne pas faire (au-dessus de descBox)
    local erreurBtn = CreateFrame("Button", nil, stratContent, "BackdropTemplate")
    erreurBtn:SetPoint("BOTTOMLEFT",  descBox, "TOPLEFT",  0, 4)
    erreurBtn:SetPoint("BOTTOMRIGHT", descBox, "TOPRIGHT", 0, 4)
    erreurBtn:SetHeight(34)
    erreurBtn:SetBackdrop(BD_TILE(16, 10))
    erreurBtn:SetBackdropColor(C_AVOID[1], C_AVOID[2], C_AVOID[3], C_AVOID[4])
    erreurBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    local erreurLbl = erreurBtn:CreateFontString(nil, "OVERLAY")
    erreurLbl:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE")
    erreurLbl:SetPoint("LEFT", erreurBtn, "LEFT", 8, 0)
    erreurLbl:SetPoint("RIGHT", erreurBtn, "RIGHT", -4, 0)
    erreurLbl:SetJustifyH("LEFT")
    erreurLbl:SetJustifyV("MIDDLE")
    erreurLbl:SetHeight(34)
    erreurLbl:SetTextColor(1.0, 0.50, 0.50)
    erreurLbl:SetText("!! ERREUR A NE PAS FAIRE")
    erreurBtn.descText = ""
    erreurBtn:SetScript("OnClick", function()
        lastSel = "avoid"
        f.descText:SetText(erreurBtn.descText)
        MBGA_RefreshStepButtons(0)
        erreurBtn:SetBackdropColor(C_AVOID_ON[1], C_AVOID_ON[2], C_AVOID_ON[3], C_AVOID_ON[4])
        f.planBBtn:SetBackdropColor(C_PLANB[1], C_PLANB[2], C_PLANB[3], C_PLANB[4])
    end)
    f.erreurBtn = erreurBtn

    -- Bouton PLAN B (au-dessus de erreurBtn)
    local planBBtn = CreateFrame("Button", nil, stratContent, "BackdropTemplate")
    planBBtn:SetPoint("BOTTOMLEFT",  erreurBtn, "TOPLEFT",  0, 4)
    planBBtn:SetPoint("BOTTOMRIGHT", erreurBtn, "TOPRIGHT", 0, 4)
    planBBtn:SetHeight(34)
    planBBtn:SetBackdrop(BD_TILE(16, 10))
    planBBtn:SetBackdropColor(C_PLANB[1], C_PLANB[2], C_PLANB[3], C_PLANB[4])
    planBBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    local planBLbl = planBBtn:CreateFontString(nil, "OVERLAY")
    planBLbl:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    planBLbl:SetPoint("LEFT", planBBtn, "LEFT", 8, 0)
    planBLbl:SetPoint("RIGHT", planBBtn, "RIGHT", -4, 0)
    planBLbl:SetJustifyH("LEFT")
    planBLbl:SetJustifyV("MIDDLE")
    planBLbl:SetHeight(34)
    planBLbl:SetTextColor(1.0, 0.65, 0.20)
    planBLbl:SetText("PLAN B")
    planBBtn.descText = ""
    planBBtn:SetScript("OnClick", function()
        lastSel = "planb"
        f.descText:SetText(planBBtn.descText)
        MBGA_RefreshStepButtons(0)
        -- Declenche le dernier step sur la carte (c'est le Plan B cartographique)
        local mapData = MBGA_BGMapData and MBGA_BGMapData[currentBGIndex]
        if mapData and mapData.steps_fr and #mapData.steps_fr > 0 then
            MBGA_DrawStepOverlays(#mapData.steps_fr)
            MBGA_HighlightNodes(mapData.steps_fr[#mapData.steps_fr])
        end
        planBBtn:SetBackdropColor(C_PLANB_ON[1], C_PLANB_ON[2], C_PLANB_ON[3], C_PLANB_ON[4])
        erreurBtn:SetBackdropColor(C_AVOID[1], C_AVOID[2], C_AVOID[3], C_AVOID[4])
    end)
    f.planBBtn = planBBtn

    -- Carte objectif (en haut du panneau strat, sous les onglets)
    local objCard = CreateFrame("Frame", nil, stratContent, "BackdropTemplate")
    objCard:SetPoint("TOPLEFT",  stratContent, "TOPLEFT",  0, 0)
    objCard:SetPoint("TOPRIGHT", stratContent, "TOPRIGHT", 0, 0)
    objCard:SetHeight(52)
    objCard:SetBackdrop(BD_TILE(16, 10))
    objCard:SetBackdropColor(C_OBJ[1], C_OBJ[2], C_OBJ[3], C_OBJ[4])
    local objHeader = objCard:CreateFontString(nil, "OVERLAY")
    objHeader:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    objHeader:SetPoint("TOPLEFT", objCard, "TOPLEFT", 6, -5)
    objHeader:SetTextColor(C_TITLE[1], C_TITLE[2], C_TITLE[3])
    objHeader:SetText("OBJECTIF PRINCIPAL")
    local objText = objCard:CreateFontString(nil, "OVERLAY")
    objText:SetFont("Fonts\\ARIALN.TTF", 10)
    objText:SetPoint("TOPLEFT",  objCard, "TOPLEFT",  6, -18)
    objText:SetPoint("TOPRIGHT", objCard, "TOPRIGHT", -6, -18)
    objText:SetHeight(30)
    objText:SetJustifyH("LEFT")
    objText:SetJustifyV("TOP")
    objText:SetTextColor(0.88, 0.88, 0.93)
    objText:SetWordWrap(true)
    objText:SetNonSpaceWrap(false)
    objText:SetText("")
    f.objCard    = objCard
    f.objText    = objText

    -- Zone des etapes (entre objCard en haut et planBBtn en bas)
    local stepsArea = CreateFrame("Frame", nil, stratContent)
    stepsArea:SetPoint("TOPLEFT",     objCard,  "BOTTOMLEFT",  0, -4)
    stepsArea:SetPoint("BOTTOMRIGHT", planBBtn, "TOPRIGHT",    0, -4)
    f.stepsArea = stepsArea

    -- ── Contenu onglet ROLES ──────────────────────────────────────────────────
    local rolesContent = CreateFrame("Frame", nil, panel)
    rolesContent:SetPoint("TOPLEFT",     panel, "TOPLEFT",     4, CTOP)
    rolesContent:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -4, 4)
    rolesContent:Hide()
    f.rolesContent = rolesContent

    -- Carte roles/classes (haut de l'onglet roles, 55% de la hauteur)
    local rolesCard = CreateFrame("Frame", nil, rolesContent, "BackdropTemplate")
    rolesCard:SetPoint("TOPLEFT",  rolesContent, "TOPLEFT",  0, 0)
    rolesCard:SetPoint("TOPRIGHT", rolesContent, "TOPRIGHT", 0, 0)
    rolesCard:SetHeight(210)
    rolesCard:SetBackdrop(BD_TILE(16, 10))
    rolesCard:SetBackdropColor(C_ROLES_A[1], C_ROLES_A[2], C_ROLES_A[3], C_ROLES_A[4])
    local rolesHeader = rolesCard:CreateFontString(nil, "OVERLAY")
    rolesHeader:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    rolesHeader:SetPoint("TOPLEFT", rolesCard, "TOPLEFT", 6, -6)
    rolesHeader:SetTextColor(C_TITLE[1], C_TITLE[2], C_TITLE[3])
    rolesHeader:SetText("ROLES ET CLASSES RECOMMANDES")
    local rolesText = rolesCard:CreateFontString(nil, "OVERLAY")
    rolesText:SetFont("Fonts\\ARIALN.TTF", 10)
    rolesText:SetPoint("TOPLEFT",  rolesCard, "TOPLEFT",  6, -20)
    rolesText:SetPoint("TOPRIGHT", rolesCard, "TOPRIGHT", -6, -20)
    rolesText:SetHeight(182)
    rolesText:SetJustifyH("LEFT")
    rolesText:SetJustifyV("TOP")
    rolesText:SetTextColor(0.82, 0.82, 0.88)
    rolesText:SetWordWrap(true)
    rolesText:SetNonSpaceWrap(false)
    rolesText:SetText("")
    f.rolesCard = rolesCard
    f.rolesText = rolesText

    -- Carte composition (bas de l'onglet roles, Phase 2 placeholder)
    local compCard = CreateFrame("Frame", nil, rolesContent, "BackdropTemplate")
    compCard:SetPoint("TOPLEFT",     rolesCard,    "BOTTOMLEFT",        0, -6)
    compCard:SetPoint("BOTTOMRIGHT", rolesContent, "BOTTOMRIGHT",       0, 0)
    compCard:SetBackdrop(BD_TILE(16, 10))
    compCard:SetBackdropColor(C_ROLES_B[1], C_ROLES_B[2], C_ROLES_B[3], C_ROLES_B[4])
    local compHeader = compCard:CreateFontString(nil, "OVERLAY")
    compHeader:SetFont("Fonts\\FRIZQT__.TTF", 10, "OUTLINE")
    compHeader:SetPoint("TOPLEFT", compCard, "TOPLEFT", 6, -6)
    compHeader:SetTextColor(0.60, 0.90, 0.60)
    compHeader:SetText("MEILLEURE COMP (PHASE 2)")
    local compText = compCard:CreateFontString(nil, "OVERLAY")
    compText:SetFont("Fonts\\ARIALN.TTF", 10)
    compText:SetPoint("TOPLEFT",  compCard, "TOPLEFT",  6, -20)
    compText:SetPoint("TOPRIGHT", compCard, "TOPRIGHT", -6, -20)
    compText:SetHeight(80)
    compText:SetJustifyH("LEFT")
    compText:SetJustifyV("TOP")
    compText:SetTextColor(0.45, 0.60, 0.45)
    compText:SetWordWrap(true)
    compText:SetNonSpaceWrap(false)
    compText:SetText("Disponible apres le scan de composition (Phase 2).\n\nLa meilleure attribution de roles sera calculee automatiquement depuis la composition de votre groupe.")

    MBGA_BGMapFrame = f

    -- Initialiser l'etat visuel des onglets
    MBGA_SwitchPanelTab("strat")
end

-- ─────────────────────────────────────────────────────────────────────────────
-- ONGLETS
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_SwitchPanelTab(tab)
    local f = MBGA_BGMapFrame
    if not f then return end
    activeTab = tab

    if tab == "strat" then
        f.stratContent:Show()
        f.rolesContent:Hide()
        f.tabStrat:SetBackdropColor(C_TAB_ON[1],  C_TAB_ON[2],  C_TAB_ON[3],  C_TAB_ON[4])
        f.tabRoles:SetBackdropColor(C_TAB_OFF[1], C_TAB_OFF[2], C_TAB_OFF[3], C_TAB_OFF[4])
        f.tabStrat.lbl:SetTextColor(C_TITLE[1], C_TITLE[2], C_TITLE[3])
        f.tabRoles.lbl:SetTextColor(0.50, 0.50, 0.55)
    else
        f.stratContent:Hide()
        f.rolesContent:Show()
        f.tabStrat:SetBackdropColor(C_TAB_OFF[1], C_TAB_OFF[2], C_TAB_OFF[3], C_TAB_OFF[4])
        f.tabRoles:SetBackdropColor(C_TAB_ON[1],  C_TAB_ON[2],  C_TAB_ON[3],  C_TAB_ON[4])
        f.tabStrat.lbl:SetTextColor(0.50, 0.50, 0.55)
        f.tabRoles.lbl:SetTextColor(C_TITLE[1], C_TITLE[2], C_TITLE[3])
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- MISE À JOUR DU CONTENU (chaque ouverture de BG)
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_UpdateBGMapContent()
    local f   = MBGA_BGMapFrame
    local idx = currentBGIndex
    local mapData = MBGA_BGMapData and MBGA_BGMapData[idx]
    local bgData  = MBGA_BGs       and MBGA_BGs[idx]

    -- Reset scale et pan
    mapScale      = 1.0
    panState.panX = 0
    panState.panY = 0
    local mp = f.mapPanel
    mp:ClearAllPoints()
    mp:SetPoint("TOPLEFT")
    mp:SetSize(MAP_W, TILE_GRID_H)
    for row = 0, TILE_ROWS - 1 do
        for col = 0, TILE_COLS - 1 do
            local i    = row * TILE_COLS + col + 1
            local tile = mp["tile" .. i]
            if tile then
                tile:SetSize(TILE_W_BASE, TILE_H_BASE)
                tile:SetPoint("TOPLEFT", mp, "TOPLEFT", col * TILE_W_BASE, -row * TILE_H_BASE)
            end
        end
    end

    -- Nom du BG
    local bg   = bgData
    local name = bg and (MBGA_L and MBGA_L[bg.nameKey] or bg.id) or ("BG " .. tostring(idx))
    f.bgNameLbl:SetText(name)

    -- Nettoyer carte
    MBGA_ClearOverlayLines()
    MBGA_ClearNodes()

    -- Langue
    local lang  = MBGA_State and MBGA_State.lang or "FR"
    local strat = bgData and bgData.strat
    local stratTx = strat and ((lang == "EN" and strat.en) or strat.fr) or nil

    -- ─── Onglet STRAT ─────────────────────────────────────────────────────────

    -- Objectif principal
    f.objText:SetText(stratTx and stratTx.objective or "")

    -- Plan B text (depuis StrategyData)
    f.planBBtn.descText = stratTx and stratTx.planB or ""
    -- Reset couleur Plan B
    f.planBBtn:SetBackdropColor(C_PLANB[1], C_PLANB[2], C_PLANB[3], C_PLANB[4])
    f.erreurBtn:SetBackdropColor(C_AVOID[1], C_AVOID[2], C_AVOID[3], C_AVOID[4])

    -- Erreur (avoid list depuis StrategyData)
    local avoid = stratTx and stratTx.avoid or {}
    local avoidStr = ""
    for _, v in ipairs(avoid) do
        avoidStr = avoidStr .. "- " .. v .. "\n"
    end
    f.erreurBtn.descText = avoidStr

    -- Description par défaut : objectif
    f.descText:SetText(stratTx and stratTx.objective or "")
    lastSel = "none"

    -- Etapes (dynamique)
    MBGA_ClearStepButtons()
    if mapData then
        MBGA_LoadMapTiles(mapData)
        MBGA_LoadMapNodes(mapData)
        MBGA_BuildStepButtons(mapData)
        MBGA_ApplyStep(1)
    else
        MBGA_LoadMapTiles(nil)
    end

    -- ─── Onglet ROLES ─────────────────────────────────────────────────────────
    local roles = stratTx and stratTx.roles or {}
    local rolesStr = ""
    for _, v in ipairs(roles) do
        rolesStr = rolesStr .. "- " .. v .. "\n"
    end
    f.rolesText:SetText(rolesStr ~= "" and rolesStr or "Roles non disponibles pour ce BG.")

    -- Mise a jour des boutons faction dans la map frame
    MBGA_UpdateMapFactionUI()

    -- Activer onglet strat
    MBGA_SwitchPanelTab("strat")
end

-- ─────────────────────────────────────────────────────────────────────────────
-- BOUTONS D'ÉTAPES (dynamiques)
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_ClearStepButtons()
    for _, btn in ipairs(stepButtons) do
        if btn then btn:Hide() end
    end
    stepButtons = {}
end

function MBGA_BuildStepButtons(data)
    local f    = MBGA_BGMapFrame
    local area = f.stepsArea

    local lang  = MBGA_State and MBGA_State.lang or "FR"
    local steps = (lang == "EN" and data.steps_en and #data.steps_en > 0)
                  and data.steps_en or data.steps_fr
    if not steps then return end

    local BTN_H   = 38
    local BTN_GAP = 4
    local numStep = 0   -- compteur d'etapes numerotees (hors Plan B)

    local prevBtn = nil

    for i, step in ipairs(steps) do
        -- Detection Plan B par le titre (string match)
        local isPlanB = step.title and step.title:lower():find("plan b")

        if not isPlanB then
            numStep = numStep + 1
            local btn = CreateFrame("Button", nil, area, "BackdropTemplate")
            btn:SetHeight(BTN_H)
            btn:SetBackdrop(BD_TILE(16, 10))
            btn:SetBackdropColor(C_STEP_OFF[1], C_STEP_OFF[2], C_STEP_OFF[3], C_STEP_OFF[4])
            btn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")

            if prevBtn then
                btn:SetPoint("TOPLEFT",  prevBtn, "BOTTOMLEFT",  0, -BTN_GAP)
                btn:SetPoint("TOPRIGHT", prevBtn, "BOTTOMRIGHT", 0, -BTN_GAP)
            else
                btn:SetPoint("TOPLEFT",  area, "TOPLEFT",  0, 0)
                btn:SetPoint("TOPRIGHT", area, "TOPRIGHT", 0, 0)
            end

            -- Numero a gauche
            local numLbl = btn:CreateFontString(nil, "OVERLAY")
            numLbl:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
            numLbl:SetPoint("LEFT", btn, "LEFT", 6, 0)
            numLbl:SetSize(20, BTN_H)
            numLbl:SetJustifyH("CENTER")
            numLbl:SetJustifyV("MIDDLE")
            numLbl:SetTextColor(0.40, 0.40, 0.50)
            numLbl:SetText(tostring(numStep))
            btn.numLbl = numLbl

            -- Titre de l'etape
            local titleLbl = btn:CreateFontString(nil, "OVERLAY")
            titleLbl:SetFont("Fonts\\ARIALN.TTF", 11, "OUTLINE")
            titleLbl:SetPoint("TOPLEFT",     btn, "TOPLEFT",     28, -4)
            titleLbl:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -4, 4)
            titleLbl:SetJustifyH("LEFT")
            titleLbl:SetJustifyV("MIDDLE")
            titleLbl:SetTextColor(0.70, 0.70, 0.76)
            titleLbl:SetWordWrap(true)
            titleLbl:SetNonSpaceWrap(false)
            titleLbl:SetText(step.title or ("Etape " .. numStep))
            btn.titleLbl = titleLbl

            -- Couleur de l'etape (petite barre gauche)
            if step.color then
                local bar = btn:CreateTexture(nil, "ARTWORK")
                bar:SetSize(3, BTN_H - 10)
                bar:SetPoint("LEFT",   btn, "LEFT", 2, 0)
                bar:SetColorTexture(step.color[1], step.color[2], step.color[3], 0.85)
            end

            local capturedIdx = i
            local capturedDesc = step.desc or ""
            btn:SetScript("OnClick", function()
                lastSel = "step"
                MBGA_ApplyStep(capturedIdx)
            end)

            btn.stepIdx = i
            prevBtn = btn
            stepButtons[#stepButtons + 1] = btn
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- APPLICATION D'UNE ÉTAPE
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_ApplyStep(stepIdx)
    local f       = MBGA_BGMapFrame
    local data    = MBGA_BGMapData and MBGA_BGMapData[currentBGIndex]
    if not data then return end

    local lang  = MBGA_State and MBGA_State.lang or "FR"
    local steps = (lang == "EN" and data.steps_en and #data.steps_en > 0)
                  and data.steps_en or data.steps_fr
    if not steps then return end

    currentStep = stepIdx
    local step  = steps[stepIdx]
    if not step then return end

    -- 1. Highlights des nodes
    MBGA_HighlightNodes(step)

    -- 2. Fleches
    MBGA_DrawStepOverlays(stepIdx)

    -- 3. Description dans descBox
    f.descText:SetText(step.desc or "")

    -- 4. Reset couleurs Plan B / Erreur
    f.planBBtn:SetBackdropColor(C_PLANB[1], C_PLANB[2], C_PLANB[3], C_PLANB[4])
    f.erreurBtn:SetBackdropColor(C_AVOID[1], C_AVOID[2], C_AVOID[3], C_AVOID[4])

    -- 5. Rafraichir boutons
    MBGA_RefreshStepButtons(stepIdx)
end

function MBGA_HighlightNodes(step)
    -- Tous les nodes en semi-transparent
    for _, blip in pairs(nodeBlips) do
        blip:SetAlpha(0.35)
        blip.ring:Hide()
        if blip.nodeBg then blip.nodeBg:SetVertexColor(0.08, 0.09, 0.12, 0.88) end
    end
    -- Nodes cibles en pleine opacite
    local cr, cg, cb = 1, 0.78, 0
    if step.color then cr=step.color[1]; cg=step.color[2]; cb=step.color[3] end

    if step.highlights then
        for _, nodeId in ipairs(step.highlights) do
            local blip = nodeBlips[nodeId]
            if blip then
                blip:SetAlpha(1)
                if blip.nodeBg then blip.nodeBg:SetVertexColor(cr*0.40, cg*0.40, cb*0.40, 0.92) end
                blip.ring:SetVertexColor(cr, cg, cb, 0.90)
                blip.ring:Show()
            end
        end
    end
end

function MBGA_RefreshStepButtons(activeIdx)
    for _, btn in ipairs(stepButtons) do
        if btn.stepIdx == activeIdx then
            btn:SetBackdropColor(C_STEP_ON[1],  C_STEP_ON[2],  C_STEP_ON[3],  C_STEP_ON[4])
            btn.numLbl:SetTextColor(1.00, 0.82, 0.10)
            btn.titleLbl:SetTextColor(1.00, 0.88, 0.60)
        else
            btn:SetBackdropColor(C_STEP_OFF[1], C_STEP_OFF[2], C_STEP_OFF[3], C_STEP_OFF[4])
            btn.numLbl:SetTextColor(0.38, 0.38, 0.48)
            btn.titleLbl:SetTextColor(0.62, 0.62, 0.68)
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- TILES
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_LoadMapTiles(data)
    local mp      = MBGA_BGMapFrame.mapPanel
    local hasTile = data and data.mapFolder and data.mapFolder ~= ""

    for i = 1, TILE_COLS * TILE_ROWS do
        local tile = mp["tile" .. i]
        if tile then
            if hasTile then
                tile:SetTexture("Interface\\WorldMap\\" .. data.mapFolder
                                .. "\\" .. data.mapFolder .. i)
            else
                tile:SetColorTexture(0.07, 0.09, 0.13, 1)
            end
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- NODES (blips)
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_ClearNodes()
    for _, blip in pairs(nodeBlips) do
        if blip then blip:Hide() end
    end
    nodeBlips = {}
end

function MBGA_LoadMapNodes(data)
    MBGA_ClearNodes()
    if not data or not data.nodes then return end
    local mp = MBGA_BGMapFrame.mapPanel

    for _, node in ipairs(data.nodes) do
        local btn = CreateFrame("Button", nil, mp)
        btn:SetSize(NODE_SIZE, NODE_SIZE)
        btn:SetFrameLevel(mp:GetFrameLevel() + 5)
        btn:SetPoint("CENTER", mp, "TOPLEFT", node.x * mapScale, -node.y * mapScale)

        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture("Interface\\Buttons\\WHITE8X8")
        bg:SetVertexColor(0.08, 0.09, 0.12, 0.88)
        bg:SetAllPoints()
        btn.nodeBg = bg

        local border = btn:CreateTexture(nil, "BORDER")
        border:SetTexture("Interface\\Buttons\\WHITE8X8")
        border:SetVertexColor(0.30, 0.30, 0.35, 0.70)
        border:SetPoint("TOPLEFT",     btn, "TOPLEFT",     -1,  1)
        border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT",  1, -1)

        local ring = btn:CreateTexture(nil, "OVERLAY", nil, 2)
        ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        ring:SetSize(RING_SIZE, RING_SIZE)
        ring:SetPoint("CENTER")
        ring:Hide()
        btn.ring = ring

        local abbr = btn:CreateFontString(nil, "OVERLAY")
        abbr:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
        abbr:SetPoint("CENTER")
        abbr:SetTextColor(1, 1, 1)
        abbr:SetText(node.id)

        local lbl = btn:CreateFontString(nil, "OVERLAY")
        lbl:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE")
        lbl:SetPoint("TOP", btn, "BOTTOM", 0, -2)
        lbl:SetJustifyH("CENTER")
        lbl:SetTextColor(0.82, 0.82, 0.88)
        lbl:SetText(node.name)

        local nodeName = node.name
        local nodeDesc = node.desc
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(nodeName, 1, 1, 1)
            if nodeDesc then GameTooltip:AddLine(nodeDesc, 0.75, 0.75, 0.80, true) end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        btn.nodeId = node.id
        btn.nodeX  = node.x
        btn.nodeY  = node.y
        nodeBlips[node.id] = btn
    end
end

function MBGA_RepositionNodes()
    local mp = MBGA_BGMapFrame.mapPanel
    for _, blip in pairs(nodeBlips) do
        if blip.nodeX then
            blip:ClearAllPoints()
            blip:SetPoint("CENTER", mp, "TOPLEFT",
                blip.nodeX * mapScale, -blip.nodeY * mapScale)
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- OVERLAYS (lignes / fleches)
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_ClearOverlayLines()
    for _, ln in ipairs(overlayLines) do
        if ln then ln:Hide() end
    end
end

local function MBGA_GetLine(idx)
    if overlayLines[idx] then return overlayLines[idx] end
    local mp = MBGA_BGMapFrame.mapPanel
    local ln = mp:CreateLine(nil, "OVERLAY", nil, 3)
    ln:SetThickness(3.5)
    overlayLines[idx] = ln
    return ln
end

function MBGA_DrawStepOverlays(stepIdx)
    MBGA_ClearOverlayLines()
    local data = MBGA_BGMapData and MBGA_BGMapData[currentBGIndex]
    if not data then return end

    local lang  = MBGA_State and MBGA_State.lang or "FR"
    local steps = (lang == "EN" and data.steps_en and #data.steps_en > 0)
                  and data.steps_en or data.steps_fr
    if not steps then return end

    local step = steps[stepIdx]
    if not step or not step.arrows then return end

    -- Lookup positions nodes + spawns
    local pos = {}
    if data.nodes then
        for _, n in ipairs(data.nodes) do pos[n.id] = n end
    end
    if data.spawn then
        if data.spawn.horde    then pos["spawn_horde"]    = data.spawn.horde    end
        if data.spawn.alliance then pos["spawn_alliance"] = data.spawn.alliance end
    end

    local cr, cg, cb, ca = 1, 0.78, 0, 1
    if step.color then
        cr=step.color[1]; cg=step.color[2]; cb=step.color[3]
        ca=step.color[4] or 1
    end

    local mp      = MBGA_BGMapFrame.mapPanel
    local lineIdx = 0
    for _, arrow in ipairs(step.arrows) do
        local p1 = (type(arrow.from)=="table") and arrow.from or pos[arrow.from]
        local p2 = (type(arrow.to)  =="table") and arrow.to   or pos[arrow.to]
        if p1 and p2 then
            lineIdx = lineIdx + 1
            local ln = MBGA_GetLine(lineIdx)
            local r2,g2,b2,a2 = cr,cg,cb,ca
            if arrow.color then
                r2=arrow.color[1]; g2=arrow.color[2]; b2=arrow.color[3]
                a2=(arrow.color[4] or 1)
            end
            ln:SetTexture("Interface\\Buttons\\WHITE8X8")
            ln:SetVertexColor(r2, g2, b2, a2 * 0.85)
            ln:SetStartPoint("TOPLEFT", mp, p1.x * mapScale, -p1.y * mapScale)
            ln:SetEndPoint(  "TOPLEFT", mp, p2.x * mapScale, -p2.y * mapScale)
            ln:Show()
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- ZOOM
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_ApplyMapScale()
    local f  = MBGA_BGMapFrame
    if not f then return end
    local mp = f.mapPanel
    local tw = TILE_W_BASE * mapScale
    local th = TILE_H_BASE * mapScale

    for row = 0, TILE_ROWS - 1 do
        for col = 0, TILE_COLS - 1 do
            local idx  = row * TILE_COLS + col + 1
            local tile = mp["tile" .. idx]
            if tile then
                tile:SetSize(tw, th)
                tile:SetPoint("TOPLEFT", mp, "TOPLEFT", col * tw, -row * th)
            end
        end
    end

    local newW = MAP_W    * mapScale
    local newH = TILE_GRID_H * mapScale
    mp:SetSize(newW, newH)

    local clip = f.clipFrame
    local maxX = math.max(0, newW - clip:GetWidth())
    local maxY = math.max(0, newH - clip:GetHeight())
    panState.panX = math.min(0, math.max(-maxX, panState.panX))
    panState.panY = math.min(0, math.max(-maxY, panState.panY))
    mp:ClearAllPoints()
    mp:SetPoint("TOPLEFT", clip, "TOPLEFT", panState.panX, panState.panY)

    MBGA_RepositionNodes()
    if currentBGIndex then MBGA_DrawStepOverlays(currentStep) end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- MISE À JOUR FACTION (appele depuis MBGA_UpdateFactionUI)
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_UpdateMapFactionUI()
    local f = MBGA_BGMapFrame
    if not f then return end

    local isHorde = (MBGA_State and MBGA_State.faction == "Horde")

    local hBtn = f.mapHordeBtn
    local aBtn = f.mapAlliBtn
    if hBtn then
        hBtn:SetBackdropColor(
            isHorde and 0.33 or 0.10,
            0.05,
            isHorde and 0.05 or 0.10,
            0.95)
    end
    if aBtn then
        aBtn:SetBackdropColor(
            isHorde and 0.06 or 0.06,
            isHorde and 0.06 or 0.14,
            isHorde and 0.12 or 0.28,
            0.95)
    end
end
"""

with open(r"d:/MBGA/UI/BGMapFrame.lua", "w", encoding="utf-8") as out:
    out.write(lua)

print("BGMapFrame.lua v2 written:", len(lua), "chars")
