-- UI/BGMapFrame.lua
-- Interface de carte interactive MDT-style pour les battlegrounds.
-- Carte scrollable + zoomable avec nodes, flèches de stratégie et panneau d'étapes.
--
-- MDT-inspired : tiles Blizzard WorldMap (4×3), blips sur nodes, CreateLine pour les flèches,
-- panneau droit avec étapes cliquables.

-- ─── Constantes de layout ─────────────────────────────────────────────────────
local FRAME_W      = 990       -- largeur totale de la fenêtre
local FRAME_H      = 620       -- hauteur totale
local HDR_H        = 44        -- hauteur du header
local MAP_W        = 760       -- largeur de la zone de carte (clip frame)
local MAP_H        = 540       -- hauteur visible de la carte
local PANEL_W      = 200       -- largeur du panneau droit (steps)
local PAD          = 10        -- padding interne global
local TILE_COLS    = 4         -- grille de tiles : 4 colonnes
local TILE_ROWS    = 3         -- 3 lignes
local TILE_W_BASE  = MAP_W / TILE_COLS  -- 190 px à scale=1
local TILE_H_BASE  = TILE_W_BASE        -- tiles carrés
local TILE_GRID_H  = TILE_H_BASE * TILE_ROWS  -- 570 px à scale=1

local SCALE_MIN    = 0.6
local SCALE_MAX    = 3.0
local SCALE_STEP   = 0.18

local NODE_SIZE    = 30        -- taille des blips de node (px)
local RING_SIZE    = 50        -- taille de l'anneau de highlight

-- ─── Couleurs sémantiques ─────────────────────────────────────────────────────
local COLOR_BG        = {0.07, 0.07, 0.09, 0.97}
local COLOR_HDR       = {0.10, 0.12, 0.16, 1.00}
local COLOR_PANEL     = {0.09, 0.09, 0.12, 0.97}
local COLOR_TITLE     = {1.00, 0.82, 0.00, 1}
local COLOR_STEP_ACTV = {0.22, 0.17, 0.04, 0.97}  -- fond dorée step actif
local COLOR_STEP_NORM = {0.12, 0.12, 0.16, 0.95}  -- fond gris step inactif

-- ─── État interne ─────────────────────────────────────────────────────────────
local currentBGIndex = nil
local currentStep    = 1
local mapScale       = 1.0

-- pool d'objets réutilisables
local nodeBlips    = {}   -- [nodeId] = Button
local overlayLines = {}   -- list de Line objects (créés une fois, réutilisés)
local stepButtons  = {}   -- list de Button dans le panneau droit

-- état pan
local panState = { active=false, startX=0, startY=0, initPanX=0, initPanY=0, panX=0, panY=0 }

-- ─────────────────────────────────────────────────────────────────────────────
-- ENTRÉE PUBLIQUE
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_OpenBGMapFrame(bgIndex)
    currentBGIndex = bgIndex
    currentStep    = 1
    mapScale       = 1.0

    if not MBGA_BGMapFrame then
        MBGA_BuildBGMapFrame()
    end

    -- Masquer la fenêtre principale
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
        bgFile   = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile=true, tileSize=32, edgeSize=26,
        insets={left=9, right=9, top=9, bottom=9},
    })
    f:SetBackdropColor(COLOR_BG[1], COLOR_BG[2], COLOR_BG[3], COLOR_BG[4])

    -- ── Header ───────────────────────────────────────────────────────────────
    local hdr = CreateFrame("Frame", nil, f, "BackdropTemplate")
    hdr:SetPoint("TOPLEFT",  f, "TOPLEFT",  PAD, -PAD)
    hdr:SetPoint("TOPRIGHT", f, "TOPRIGHT", -PAD, -PAD)
    hdr:SetHeight(HDR_H)
    hdr:SetBackdrop({
        bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, tileSize=16, edgeSize=10,
        insets={left=3, right=3, top=3, bottom=3},
    })
    hdr:SetBackdropColor(COLOR_HDR[1], COLOR_HDR[2], COLOR_HDR[3], COLOR_HDR[4])
    f.header = hdr

    -- Bouton ← Retour
    local backBtn = CreateFrame("Button", nil, hdr, "BackdropTemplate")
    backBtn:SetSize(80, 28)
    backBtn:SetPoint("LEFT", hdr, "LEFT", 8, 0)
    backBtn:SetBackdrop({
        bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, tileSize=16, edgeSize=10,
        insets={left=3, right=3, top=3, bottom=3},
    })
    backBtn:SetBackdropColor(0.15, 0.15, 0.20, 0.95)
    backBtn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")
    local backLbl = backBtn:CreateFontString(nil, "OVERLAY")
    backLbl:SetFont("Fonts\\ARIALN.TTF", 13, "OUTLINE")
    backLbl:SetAllPoints()
    backLbl:SetJustifyH("CENTER")
    backLbl:SetText("← Retour")
    backLbl:SetTextColor(0.80, 0.80, 0.85)
    backBtn:SetScript("OnClick", function()
        MBGA_BGMapFrame:Hide()
        if MBGA_MainFrame then MBGA_MainFrame:Show() end
    end)
    f.backBtn = backBtn

    -- Titre du BG (centré dans le header)
    local bgTitle = hdr:CreateFontString(nil, "OVERLAY")
    bgTitle:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")
    bgTitle:SetPoint("CENTER", hdr, "CENTER", 0, 0)
    bgTitle:SetTextColor(COLOR_TITLE[1], COLOR_TITLE[2], COLOR_TITLE[3])
    bgTitle:SetText("")
    f.bgTitle = bgTitle

    -- Bouton fermer (X haut-droit)
    local closeBtn = CreateFrame("Button", nil, hdr, "UIPanelCloseButton")
    closeBtn:SetPoint("RIGHT", hdr, "RIGHT", -2, 0)

    -- ── Zone de carte : clipFrame + mapPanel ────────────────────────────────
    -- clipFrame sert de fenêtre visible sur la carte (clips les débords)
    local clipFrame = CreateFrame("Frame", "MBGA_MapClip", f)
    clipFrame:SetPoint("TOPLEFT", f, "TOPLEFT", PAD, -(PAD + HDR_H + 8))
    clipFrame:SetSize(MAP_W, MAP_H)
    clipFrame:SetClipsChildren(true)
    f.clipFrame = clipFrame

    -- Fond de la zone de carte (couleur de remplacement si les tiles ne chargent pas)
    local mapBg = clipFrame:CreateTexture(nil, "BACKGROUND")
    mapBg:SetAllPoints()
    mapBg:SetColorTexture(0.06, 0.07, 0.10, 1)

    -- mapPanel : enfant du clipFrame, reçoit les tiles, nodes et lignes
    -- Sa taille s'adapte au zoom ; ses coordonnées bougent lors du pan
    local mapPanel = CreateFrame("Frame", "MBGA_MapPanel", clipFrame)
    mapPanel:SetSize(MAP_W, TILE_GRID_H)
    mapPanel:SetPoint("TOPLEFT")
    mapPanel:EnableMouse(false)  -- le clipFrame gère la souris
    f.mapPanel = mapPanel

    -- 12 tiles disposés en grille 4×3 dans le mapPanel
    for row = 0, TILE_ROWS - 1 do
        for col = 0, TILE_COLS - 1 do
            local idx  = row * TILE_COLS + col + 1
            local tile = mapPanel:CreateTexture("MBGA_Tile" .. idx, "BACKGROUND", nil, -2)
            tile:SetSize(TILE_W_BASE, TILE_H_BASE)
            tile:SetPoint("TOPLEFT", mapPanel, "TOPLEFT", col * TILE_W_BASE, -row * TILE_H_BASE)
            mapPanel["tile" .. idx] = tile
        end
    end

    -- tile1 = ancre principale pour toutes les positions (TOPLEFT du canvas)
    f.tile1 = mapPanel.tile1

    -- ── Pan via clic-glisser sur le clipFrame ────────────────────────────────
    clipFrame:EnableMouse(true)
    clipFrame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            panState.active   = true
            panState.startX,
            panState.startY   = GetCursorPosition()
            panState.initPanX = panState.panX
            panState.initPanY = panState.panY
        end
    end)
    clipFrame:SetScript("OnMouseUp", function(self, button)
        if button == "LeftButton" then
            panState.active = false
        end
    end)
    clipFrame:SetScript("OnUpdate", function(self)
        if not panState.active then return end
        local cx, cy = GetCursorPosition()
        local scl    = UIParent:GetEffectiveScale()
        local dx     = (cx - panState.startX) / scl
        local dy     = (cy - panState.startY) / scl
        local mp     = MBGA_BGMapFrame.mapPanel
        local maxX   = math.max(0, mp:GetWidth()  - MAP_W)
        local maxY   = math.max(0, mp:GetHeight() - MAP_H)
        -- panX : clamper entre -maxX et 0
        panState.panX = math.min(0, math.max(-maxX, panState.initPanX + dx))
        -- panY : clamper entre -maxY et 0  (y négatif = carte décalée vers le haut = scroll vers le bas)
        panState.panY = math.min(0, math.max(-maxY, panState.initPanY + dy))
        mp:ClearAllPoints()
        mp:SetPoint("TOPLEFT", self, "TOPLEFT", panState.panX, panState.panY)
    end)

    -- ── Zoom via molette ─────────────────────────────────────────────────────
    clipFrame:EnableMouseWheel(true)
    clipFrame:SetScript("OnMouseWheel", function(self, delta)
        local newScale = mapScale + delta * SCALE_STEP
        newScale = math.max(SCALE_MIN, math.min(SCALE_MAX, newScale))
        if newScale ~= mapScale then
            mapScale = newScale
            MBGA_ApplyMapScale()
        end
    end)

    -- ── Panneau droit (steps) ─────────────────────────────────────────────────
    local panel = CreateFrame("Frame", nil, f, "BackdropTemplate")
    panel:SetPoint("TOPLEFT",     clipFrame, "TOPRIGHT",   8, 0)
    panel:SetPoint("BOTTOMRIGHT", f,         "BOTTOMRIGHT", -PAD, PAD)
    panel:SetBackdrop({
        bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, tileSize=16, edgeSize=10,
        insets={left=3, right=3, top=3, bottom=3},
    })
    panel:SetBackdropColor(COLOR_PANEL[1], COLOR_PANEL[2], COLOR_PANEL[3], COLOR_PANEL[4])
    f.stepsPanel = panel

    -- Titre du panneau
    local panelTitle = panel:CreateFontString(nil, "OVERLAY")
    panelTitle:SetFont("Fonts\\FRIZQT__.TTF", 11, "OUTLINE")
    panelTitle:SetPoint("TOP", panel, "TOP", 0, -10)
    panelTitle:SetTextColor(COLOR_TITLE[1], COLOR_TITLE[2], COLOR_TITLE[3])
    panelTitle:SetText("STRATÉGIE")
    f.panelTitle = panelTitle

    -- Séparateur sous le titre du panneau
    local panSep = panel:CreateTexture(nil, "ARTWORK")
    panSep:SetColorTexture(0.35, 0.28, 0.08, 0.7)
    panSep:SetHeight(1)
    panSep:SetPoint("TOPLEFT",  panel, "TOPLEFT",  6, -28)
    panSep:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -6, -28)

    -- Zone de description (bas du panneau)
    local descBox = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    descBox:SetPoint("BOTTOMLEFT",  panel, "BOTTOMLEFT",  6,  6)
    descBox:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -6, 6)
    descBox:SetHeight(135)
    descBox:SetBackdrop({
        bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
        tile=true, tileSize=16, edgeSize=10,
        insets={left=3, right=3, top=3, bottom=3},
    })
    descBox:SetBackdropColor(0.05, 0.05, 0.08, 0.95)
    f.descBox = descBox

    local descText = descBox:CreateFontString(nil, "OVERLAY")
    descText:SetFont("Fonts\\ARIALN.TTF", 11)
    descText:SetPoint("TOPLEFT",  descBox, "TOPLEFT",  7, -7)
    descText:SetPoint("TOPRIGHT", descBox, "TOPRIGHT", -7, -7)
    descText:SetHeight(121)
    descText:SetJustifyH("LEFT")
    descText:SetJustifyV("TOP")
    descText:SetTextColor(0.78, 0.78, 0.83)
    descText:SetWordWrap(true)
    descText:SetNonSpaceWrap(false)
    f.descText = descText

    -- Séparateur au-dessus de la descBox
    local descSep = panel:CreateTexture(nil, "ARTWORK")
    descSep:SetColorTexture(0.28, 0.28, 0.33, 0.5)
    descSep:SetHeight(1)
    descSep:SetPoint("BOTTOMLEFT",  descBox, "TOPLEFT",  0, 4)
    descSep:SetPoint("BOTTOMRIGHT", descBox, "TOPRIGHT", 0, 4)

    -- Hint de zoom (bas du clipFrame)
    local zoomHint = f:CreateFontString(nil, "OVERLAY")
    zoomHint:SetFont("Fonts\\ARIALN.TTF", 9)
    zoomHint:SetPoint("BOTTOMLEFT", clipFrame, "BOTTOMLEFT", 4, 3)
    zoomHint:SetTextColor(0.35, 0.35, 0.40)
    zoomHint:SetText("Molette = zoom · Clic-glisser = déplacer")

    MBGA_BGMapFrame = f
end

-- ─────────────────────────────────────────────────────────────────────────────
-- MISE À L'ÉCHELLE (zoom)
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_ApplyMapScale()
    local f  = MBGA_BGMapFrame
    if not f then return end
    local mp = f.mapPanel
    local tw = TILE_W_BASE * mapScale
    local th = TILE_H_BASE * mapScale

    -- Repositionner toutes les tiles dans la grille
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

    -- Redimensionner le mapPanel lui-même
    mp:SetSize(MAP_W * mapScale, TILE_GRID_H * mapScale)

    -- Ajuster le pan pour rester dans les limites
    local maxX = math.max(0, mp:GetWidth()  - MAP_W)
    local maxY = math.max(0, mp:GetHeight() - MAP_H)
    panState.panX = math.min(0, math.max(-maxX, panState.panX))
    panState.panY = math.min(0, math.max(-maxY, panState.panY))
    mp:ClearAllPoints()
    mp:SetPoint("TOPLEFT", f.clipFrame, "TOPLEFT", panState.panX, panState.panY)

    -- Repositionner les nodes
    MBGA_RepositionNodes()

    -- Redessiner les flèches du step courant
    if currentBGIndex then
        MBGA_DrawStepOverlays(currentStep)
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- MISE À JOUR DU CONTENU (appelé à chaque ouverture d'un BG)
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_UpdateBGMapContent()
    local f   = MBGA_BGMapFrame
    local idx = currentBGIndex
    local data = MBGA_BGMapData and MBGA_BGMapData[idx]

    -- Reset scale et position
    mapScale    = 1.0
    panState.panX = 0
    panState.panY = 0
    local mp = f.mapPanel
    mp:ClearAllPoints()
    mp:SetPoint("TOPLEFT")
    mp:SetSize(MAP_W, TILE_GRID_H)

    -- Remettre les tiles à scale=1
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

    -- Titre
    if data then
        local bg   = MBGA_BGs and MBGA_BGs[idx]
        local name = bg and (MBGA_L and MBGA_L[bg.nameKey] or bg.id) or ("BG " .. idx)
        f.bgTitle:SetText(name)
    else
        f.bgTitle:SetText("BG " .. tostring(idx))
    end

    -- Nettoyer les overlays
    MBGA_ClearOverlayLines()
    MBGA_ClearNodes()

    if not data then
        MBGA_LoadMapTiles(nil)
        if f.descText then f.descText:SetText("Données cartographiques non disponibles.") end
        return
    end

    MBGA_LoadMapTiles(data)
    MBGA_LoadMapNodes(data)
    MBGA_UpdateStepsPanel(data)
    MBGA_ApplyStep(1)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- CHARGEMENT DES TILES
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_LoadMapTiles(data)
    local f  = MBGA_BGMapFrame
    local mp = f.mapPanel
    local hasTiles = data and data.mapFolder and data.mapFolder ~= ""

    for i = 1, TILE_COLS * TILE_ROWS do
        local tile = mp["tile" .. i]
        if tile then
            if hasTiles then
                -- Chemin standard des tiles Blizzard WorldMap : Interface\WorldMap\<Dossier>\<Dossier>N
                tile:SetTexture("Interface\\WorldMap\\" .. data.mapFolder .. "\\" .. data.mapFolder .. i)
            else
                -- Pas de tiles disponibles : fond uni (calibration ou nouveau BG)
                tile:SetColorTexture(0.07, 0.09, 0.13, 1)
            end
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- NODES (blips sur la carte)
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_ClearNodes()
    for _, blip in pairs(nodeBlips) do
        blip:Hide()
    end
    nodeBlips = {}
end

function MBGA_LoadMapNodes(data)
    MBGA_ClearNodes()
    if not data or not data.nodes then return end

    local f  = MBGA_BGMapFrame
    local mp = f.mapPanel

    for _, node in ipairs(data.nodes) do
        local btn = CreateFrame("Button", nil, mp)
        btn:SetSize(NODE_SIZE, NODE_SIZE)
        btn:SetFrameLevel(mp:GetFrameLevel() + 5)
        btn:SetPoint("CENTER", mp, "TOPLEFT", node.x * mapScale, -node.y * mapScale)

        -- Fond du node (couleur sombre)
        local bg = btn:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture("Interface\\Buttons\\WHITE8X8")
        bg:SetVertexColor(0.08, 0.09, 0.12, 0.88)
        bg:SetAllPoints()
        btn.nodeBg = bg

        -- Bordure légère
        local border = btn:CreateTexture(nil, "BORDER")
        border:SetTexture("Interface\\Buttons\\WHITE8X8")
        border:SetVertexColor(0.30, 0.30, 0.35, 0.70)
        border:SetPoint("TOPLEFT",     btn, "TOPLEFT",     -1,  1)
        border:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT",  1, -1)
        btn.border = border

        -- Anneau de highlight (visible quand le node est ciblé par une étape)
        local ring = btn:CreateTexture(nil, "OVERLAY", nil, 2)
        ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
        ring:SetSize(RING_SIZE, RING_SIZE)
        ring:SetPoint("CENTER")
        ring:Hide()
        btn.ring = ring

        -- Abréviation (2-3 lettres, style MDT)
        local abbr = btn:CreateFontString(nil, "OVERLAY")
        abbr:SetFont("Fonts\\FRIZQT__.TTF", 9, "OUTLINE")
        abbr:SetPoint("CENTER", btn, "CENTER", 0, 0)
        abbr:SetTextColor(1, 1, 1)
        abbr:SetText(node.id)
        btn.abbr = abbr

        -- Label complet sous le blip
        local lbl = btn:CreateFontString(nil, "OVERLAY")
        lbl:SetFont("Fonts\\ARIALN.TTF", 9, "OUTLINE")
        lbl:SetPoint("TOP", btn, "BOTTOM", 0, -2)
        lbl:SetJustifyH("CENTER")
        lbl:SetTextColor(0.82, 0.82, 0.88)
        lbl:SetText(node.name)
        btn.lbl = lbl

        -- Tooltip
        local nodeId   = node.id
        local nodeName = node.name
        local nodeDesc = node.desc
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()
            GameTooltip:AddLine(nodeName, 1, 1, 1)
            if nodeDesc then
                GameTooltip:AddLine(nodeDesc, 0.75, 0.75, 0.80, true)
            end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        -- Métadonnées pour le repositionnement lors du zoom
        btn.nodeId = node.id
        btn.nodeX  = node.x
        btn.nodeY  = node.y

        nodeBlips[node.id] = btn
    end
end

function MBGA_RepositionNodes()
    local f  = MBGA_BGMapFrame
    if not f then return end
    local mp = f.mapPanel
    for _, blip in pairs(nodeBlips) do
        if blip.nodeX then
            blip:ClearAllPoints()
            blip:SetPoint("CENTER", mp, "TOPLEFT",
                blip.nodeX * mapScale,
                -blip.nodeY * mapScale)
        end
    end
end

-- ─────────────────────────────────────────────────────────────────────────────
-- OVERLAYS (lignes / flèches entre nodes)
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_ClearOverlayLines()
    for _, ln in ipairs(overlayLines) do
        if ln then ln:Hide() end
    end
end

-- Récupère ou crée le Nième objet Line (réutilisation de pool)
local function MBGA_GetLine(idx)
    if overlayLines[idx] then return overlayLines[idx] end
    local f  = MBGA_BGMapFrame
    local mp = f.mapPanel
    local ln = mp:CreateLine(nil, "OVERLAY", nil, 3)
    ln:SetThickness(3.5)
    overlayLines[idx] = ln
    return ln
end

-- Dessine toutes les flèches d'une étape (sans toucher aux node highlights)
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

    -- Table de lookup positions nodes + spawns
    local pos = {}
    if data.nodes then
        for _, n in ipairs(data.nodes) do pos[n.id] = n end
    end
    if data.spawn then
        if data.spawn.horde    then pos["spawn_horde"]    = data.spawn.horde    end
        if data.spawn.alliance then pos["spawn_alliance"] = data.spawn.alliance end
    end

    -- Couleur de base de l'étape
    local cr, cg, cb, ca = 1, 0.78, 0, 1
    if step.color then
        cr = step.color[1]; cg = step.color[2]; cb = step.color[3]
        ca = step.color[4] or 1
    end

    local f  = MBGA_BGMapFrame
    local mp = f.mapPanel
    local lineIdx = 0

    for _, arrow in ipairs(step.arrows) do
        local p1 = type(arrow.from) == "table" and arrow.from or pos[arrow.from]
        local p2 = type(arrow.to)   == "table" and arrow.to   or pos[arrow.to]
        if p1 and p2 then
            lineIdx = lineIdx + 1
            local ln = MBGA_GetLine(lineIdx)
            local r2, g2, b2, a2 = cr, cg, cb, ca
            if arrow.color then
                r2=arrow.color[1]; g2=arrow.color[2]; b2=arrow.color[3]
                a2=arrow.color[4] or 1
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
-- APPLICATION D'UNE ÉTAPE (nodes + flèches + description + step buttons)
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_ApplyStep(stepIdx)
    local f  = MBGA_BGMapFrame
    local data = MBGA_BGMapData and MBGA_BGMapData[currentBGIndex]
    if not data then return end

    local lang  = MBGA_State and MBGA_State.lang or "FR"
    local steps = (lang == "EN" and data.steps_en and #data.steps_en > 0)
                  and data.steps_en or data.steps_fr
    if not steps then return end

    currentStep = stepIdx
    local step  = steps[stepIdx]
    if not step then return end

    -- Couleur de l'étape
    local cr, cg, cb = 1, 0.78, 0
    if step.color then cr=step.color[1]; cg=step.color[2]; cb=step.color[3] end

    -- 1) Réinitialiser tous les nodes (semi-transparents, ring caché)
    for _, blip in pairs(nodeBlips) do
        blip:SetAlpha(0.38)
        blip.ring:Hide()
        blip.nodeBg:SetVertexColor(0.08, 0.09, 0.12, 0.88)
    end

    -- 2) Activer les highlights des nodes ciblés par cette étape
    if step.highlights then
        for _, nodeId in ipairs(step.highlights) do
            local blip = nodeBlips[nodeId]
            if blip then
                blip:SetAlpha(1)
                blip.nodeBg:SetVertexColor(cr * 0.40, cg * 0.40, cb * 0.40, 0.92)
                blip.ring:SetVertexColor(cr, cg, cb, 0.90)
                blip.ring:Show()
            end
        end
    end

    -- 3) Dessiner les flèches
    MBGA_DrawStepOverlays(stepIdx)

    -- 4) Mettre à jour la description
    if f.descText then
        f.descText:SetText(step.desc or "")
    end

    -- 5) Rafraîchir l'état visuel des boutons de step
    MBGA_RefreshStepButtons(stepIdx, #steps)
end

-- ─────────────────────────────────────────────────────────────────────────────
-- PANNEAU D'ÉTAPES (droite)
-- ─────────────────────────────────────────────────────────────────────────────

function MBGA_UpdateStepsPanel(data)
    local f     = MBGA_BGMapFrame
    if not f or not f.stepsPanel then return end

    -- Nettoyage des anciens boutons
    for _, btn in ipairs(stepButtons) do
        btn:Hide()
    end
    stepButtons = {}

    local lang  = MBGA_State and MBGA_State.lang or "FR"
    local steps = (lang == "EN" and data.steps_en and #data.steps_en > 0)
                  and data.steps_en or data.steps_fr
    if not steps or #steps == 0 then return end

    local panel  = f.stepsPanel
    local btnH   = 46
    local btnGap = 5
    -- Zone disponible : entre le titre du panneau (y=-32) et le haut de la descBox
    -- descBox height=135, separator=4, bottom padding=6 → descBox top ≈ 145+6+4 = 155 depuis le bas
    -- panel height ≈ MAP_H = 540, donc zone steps = 540 - 32 - 155 = ~353 px
    local startY = -34   -- offset depuis le TOP du panneau (après le titre + sep)

    for i, step in ipairs(steps) do
        local btn = CreateFrame("Button", nil, panel, "BackdropTemplate")
        btn:SetHeight(btnH)
        btn:SetPoint("TOPLEFT",  panel, "TOPLEFT",  6, startY - (i - 1) * (btnH + btnGap))
        btn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -6, startY - (i - 1) * (btnH + btnGap))
        btn:SetBackdrop({
            bgFile="Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile="Interface\\Tooltips\\UI-Tooltip-Border",
            tile=true, tileSize=16, edgeSize=10,
            insets={left=3, right=3, top=3, bottom=3},
        })
        btn:SetBackdropColor(COLOR_STEP_NORM[1], COLOR_STEP_NORM[2],
                             COLOR_STEP_NORM[3], COLOR_STEP_NORM[4])
        btn:SetHighlightTexture("Interface\\Buttons\\ButtonHiLight-Square", "ADD")

        -- Numéro du step (gauche)
        local numLbl = btn:CreateFontString(nil, "OVERLAY")
        numLbl:SetFont("Fonts\\FRIZQT__.TTF", 13, "OUTLINE")
        numLbl:SetPoint("LEFT", btn, "LEFT", 7, 0)
        numLbl:SetText(tostring(i))
        numLbl:SetTextColor(0.45, 0.45, 0.55)
        btn.numLbl = numLbl

        -- Titre du step
        local titleLbl = btn:CreateFontString(nil, "OVERLAY")
        titleLbl:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
        titleLbl:SetPoint("TOPLEFT",     btn, "TOPLEFT",     24, -5)
        titleLbl:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -5, 5)
        titleLbl:SetJustifyH("LEFT")
        titleLbl:SetJustifyV("MIDDLE")
        titleLbl:SetTextColor(0.72, 0.72, 0.78)
        titleLbl:SetWordWrap(true)
        titleLbl:SetNonSpaceWrap(false)
        titleLbl:SetText(step.title or ("Étape " .. i))
        btn.titleLbl = titleLbl

        -- Capture de l'index pour le callback
        local capturedIdx = i
        btn:SetScript("OnClick", function()
            MBGA_ApplyStep(capturedIdx)
        end)

        stepButtons[i] = btn
    end

    -- Initialiser avec le step 1 actif
    MBGA_RefreshStepButtons(1, #steps)
end

-- Met à jour l'apparence visuelle des boutons (actif / inactif)
function MBGA_RefreshStepButtons(activeIdx, totalSteps)
    for i, btn in ipairs(stepButtons) do
        if i == activeIdx then
            btn:SetBackdropColor(COLOR_STEP_ACTV[1], COLOR_STEP_ACTV[2],
                                 COLOR_STEP_ACTV[3], COLOR_STEP_ACTV[4])
            btn.numLbl:SetTextColor(1.00, 0.82, 0.10)
            btn.titleLbl:SetTextColor(1.00, 0.88, 0.60)
        else
            btn:SetBackdropColor(COLOR_STEP_NORM[1], COLOR_STEP_NORM[2],
                                 COLOR_STEP_NORM[3], COLOR_STEP_NORM[4])
            btn.numLbl:SetTextColor(0.38, 0.38, 0.48)
            btn.titleLbl:SetTextColor(0.58, 0.58, 0.64)
        end
    end
end
