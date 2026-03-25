-- Core/BGMapData.lua
-- Données cartographiques pour les 15 BGs : positions des nodes, spawns, étapes stratégiques.
--
-- Système de coordonnées (x, y) en pixels depuis le coin HAUT-GAUCHE du canvas :
--   x positif = vers la droite  |  y positif = vers le bas
--   Canvas de référence à scale=1 : 760 × 570 px (grille 4×3 de tiles de 190px)
--
-- NOTE : les positions sont approximatives. Calibrer in-game après les premières sessions.

MBGA_BGMapData = {}

-- ─── Couleurs des étapes ──────────────────────────────────────────────────────
local C_GREEN  = {0.20, 0.90, 0.35, 1}   -- offensive / rush initial
local C_GOLD   = {1.00, 0.78, 0.00, 1}   -- tenue / positionnement
local C_ORANGE = {1.00, 0.50, 0.10, 1}   -- plan B / pivot
local C_RED    = {0.95, 0.20, 0.20, 1}   -- objectif final / boss

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 1 : WARSONG GULCH — CTF 10v10
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[1] = {
    mapFolder = "WarsongGulch",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="HF",  name="Base Horde",    x=615, y=90,  desc="Salle du drapeau Horde" },
        { id="AF",  name="Base Alliance", x=145, y=480, desc="Salle du drapeau Alliance" },
        { id="MID", name="Milieu",        x=380, y=285, desc="Zone centrale de fight" },
        { id="TUN", name="Tunnels",       x=380, y=355, desc="Tunnels sous le milieu" },
    },
    spawn = {
        horde    = { x=660, y=50  },
        alliance = { x=100, y=520 },
    },
    steps_fr = {
        {
            title      = "Formation de départ",
            desc       = "FC mobile part si possible en furtif ou avec escort.\n2-3 offense rush la base adverse.\n1-2 défense sur votre flag.\n⚠ Règle des 30s : le FC survit SEUL les 30 premières secondes.",
            highlights = { "HF", "AF" },
            arrows     = {
                { from="spawn_alliance", to="HF" },
                { from="spawn_horde",    to="AF" },
            },
            color = C_GREEN,
        },
        {
            title      = "Run d'escorte",
            desc       = "FC a pris le flag : REJOIN-le maintenant.\nEscort devant, healer derrière.\nCC les interceptors dans les tunnels.\nDéfenseurs : max 2 sur votre flag.",
            highlights = { "MID", "TUN" },
            arrows     = {
                { from="HF", to="AF" },
                { from="AF", to="HF" },
            },
            color = C_GOLD,
        },
        {
            title      = "Plan B (0-2)",
            desc       = "8 joueurs → défense totale de votre flag.\n2 Rogues → ninja le flag ennemi quand leur base se dégarnie.\nNe produisez plus de runs offensifs classiques.",
            highlights = { "AF", "HF" },
            arrows     = nil,
            color      = C_ORANGE,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 2 : TWIN PEAKS — CTF 10v10
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[2] = {
    mapFolder = "TwinPeaks",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="HF",    name="Base Horde",    x=615, y=90,  desc="Salle du drapeau Horde" },
        { id="AF",    name="Base Alliance", x=145, y=480, desc="Salle du drapeau Alliance" },
        { id="MID",   name="Pont",          x=380, y=285, desc="Pont central" },
        { id="CLIFF", name="Falaise",       x=530, y=185, desc="Falaise côté Alliance — knockbacks !" },
    },
    spawn = {
        horde    = { x=660, y=50  },
        alliance = { x=100, y=520 },
    },
    steps_fr = {
        {
            title      = "Priorité offensive",
            desc       = "Twin Peaks = plus ouvert que WSG → investissez plus dans l'attaque.\nSi vous gagnez la course d'échange, vous gagnez le match.\nFC sur la falaise : restez loin des bords !",
            highlights = { "HF", "AF" },
            arrows     = {
                { from="spawn_alliance", to="HF" },
                { from="spawn_horde",    to="AF" },
            },
            color = C_GREEN,
        },
        {
            title      = "Attention à la falaise",
            desc       = "Côté Alliance : knockbacks sur la falaise extérieure.\nStun / Silence les knockbackers AVANT qu'ils s'approchent du FC.\nEscort du FC : positionnez-vous DEVANT lui, pas derrière.",
            highlights = { "CLIFF", "MID" },
            arrows     = nil,
            color      = C_GOLD,
        },
        {
            title      = "Plan B (0-2)",
            desc       = "Verrouillez votre base.\nForcez un ninja flag quand l'équipe ennemie surpush.\n2 Rogues en mission ninja pendant que 8 défendent.",
            highlights = { "AF", "HF" },
            arrows     = nil,
            color      = C_ORANGE,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 3 : ARATHI BASIN — Domination 15v15
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[3] = {
    mapFolder = "ArathiBasin40",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="LM",   name="Moulin",  x=140, y=130, desc="Lumber Mill — falaise, knockbacks décisifs" },
        { id="FARM", name="Ferme",   x=620, y=130, desc="Farm — node de départ Horde" },
        { id="BS",   name="Forge",   x=380, y=290, desc="Blacksmith — node central disputé, MAX 2 !" },
        { id="ST",   name="Ecurie",  x=140, y=445, desc="Stables — node de départ Alliance" },
        { id="MINE", name="Mine",    x=620, y=445, desc="Mine — fight initial décisif" },
    },
    spawn = {
        alliance = { x=95,  y=475 },
        horde    = { x=665, y=100 },
    },
    steps_fr = {
        {
            title      = "Rush 3 nodes simultané",
            desc       = "3 groupes capent leur triangle EN MÊME TEMPS.\nAlliance : ST + BS + LM.\nHorde : FARM + BS + MINE.\nMINE : Ret Pala pop TOUS ses CDs d'entrée.\n⚠ NE JAMAIS envoyer 3+ au BS.",
            highlights = { "ST", "BS", "LM" },
            arrows     = {
                { from="spawn_alliance", to="ST"   },
                { from="spawn_alliance", to="BS"   },
                { from="spawn_alliance", to="LM"   },
                { from="spawn_horde",    to="FARM" },
                { from="spawn_horde",    to="BS"   },
                { from="spawn_horde",    to="MINE" },
            },
            color = C_GREEN,
        },
        {
            title      = "Tenez 3 nodes — max 2 à BS",
            desc       = "BS : 1 healer tanky + 1 DPS disruptif MAXIMUM.\nJouez PASSIF au BS : CC, spin, survivre.\nLM : 1 healer + 1 DPS avec knockback.\nContestez leurs nodes pour forcer les rotations adverses.",
            highlights = { "ST", "BS", "LM" },
            arrows     = nil,
            color      = C_GOLD,
        },
        {
            title      = "Plan B : pivot et contestez",
            desc       = "Si vous perdez le tempo : arrêtez les pushes inutiles.\nReprenez UN node isolé en force (5v0), puis stabilisez.\nEnvoyez 1-2 contester leur triangle pour forcer leur retour.",
            highlights = { "BS" },
            arrows     = {
                { from="ST",   to="MINE" },
                { from="LM",   to="FARM" },
            },
            color = C_ORANGE,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 4 : EYE OF THE STORM — Dom+CTF 15v15
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[4] = {
    mapFolder = "EyeOfTheStorm",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="FRR",  name="Ruines FRR",     x=130, y=130, desc="Fel Reaver Ruins — nord-ouest" },
        { id="MT",   name="Tour des Mages", x=630, y=130, desc="Mage Tower — nord-est" },
        { id="FLAG", name="Drapeau",        x=380, y=290, desc="Drapeau central — NE PAS capper avec 2 tours !" },
        { id="BET",  name="Tour BE",        x=130, y=450, desc="Blood Elf Tower — sud-ouest" },
        { id="DR",   name="Ruines DR",      x=630, y=450, desc="Draenic Ruins — sud-est" },
    },
    spawn = {
        alliance = { x=380, y=50  },
        horde    = { x=380, y=520 },
    },
    steps_fr = {
        {
            title      = "2 nodes — DROP le drapeau",
            desc       = "Capez 2 tours opposées (ex: FRR + MT).\nAvec 2 tours, DROPEZ le drapeau (clic droit → retirer le buff).\nL'ennemi doit aller le chercher = il quitte ses positions.\nNE CAPEZ JAMAIS le flag si 2 nodes suffisent.",
            highlights = { "FRR", "MT" },
            arrows     = {
                { from="spawn_alliance", to="FRR" },
                { from="spawn_alliance", to="MT"  },
                { from="spawn_horde",    to="BET" },
                { from="spawn_horde",    to="DR"  },
            },
            color = C_GREEN,
        },
        {
            title      = "Rotation toute la map",
            desc       = "Si ça bascule en mode CTF complet : plus de 'votre côté / leur côté'.\n1 healer par node, mobilité > fights.\nAllez TOUJOURS au node vide, pas au fight en cours.",
            highlights = { "FRR", "MT", "BET", "DR" },
            arrows     = nil,
            color      = C_GOLD,
        },
        {
            title      = "Cap final (timing précis)",
            desc       = "3 tours à ~1850 pts → capez immédiatement.\n2 tours : attendez ~1900 pts.\nGardez le drapeau en main jusqu'au bon moment.\nAttendez que la team soit repositionnée avant de capper.",
            highlights = { "FLAG" },
            arrows     = nil,
            color      = C_ORANGE,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 5 : BATTLE FOR GILNEAS — Domination 15v15
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[5] = {
    mapFolder = "GilneasBG",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="LH",   name="Phare",      x=130, y=285, desc="Lighthouse — sud-ouest" },
        { id="WW",   name="Waterworks", x=380, y=285, desc="Waterworks — spin permanent !" },
        { id="MINE", name="Mine",       x=630, y=285, desc="Mine — nord-est" },
    },
    spawn = {
        alliance = { x=130, y=500 },
        horde    = { x=630, y=80  },
    },
    steps_fr = {
        {
            title      = "Capez WW + 1 flanc",
            desc       = "WW = spin permanent. Ne lâchez JAMAIS le WW face à l'ennemi.\nMatchez les envois : 2 DPS ennemis → 1 DPS MOBILE (DH, Boomkin), pas un healer du WW.\nShadow Sight (buff violet) : prenez-le pour voir les stealthers.",
            highlights = { "WW", "LH" },
            arrows     = {
                { from="spawn_alliance", to="LH" },
                { from="spawn_alliance", to="WW" },
                { from="spawn_horde",    to="MINE" },
                { from="spawn_horde",    to="WW"   },
            },
            color = C_GREEN,
        },
        {
            title      = "Spin le WW — match numbers",
            desc       = "WW : CC les heals ennemis, interrompez leurs sorts, stoppez les drinks.\nNE sortez PAS votre healer du WW pour matcher 2 DPS ennemis.\nFloater : gardez l'œil sur BGE pour anticiper les rotations.",
            highlights = { "WW" },
            arrows     = nil,
            color      = C_GOLD,
        },
        {
            title      = "Récupération",
            desc       = "Si une base tombe : regroupez-vous avant de récap.\nNe ghostez QUE si vous êtes certain de tenir ET de forcer leur retour.\nGhosting raté = down 1 joueur + perte de position. Double peine.",
            highlights = { "LH", "MINE" },
            arrows     = {
                { from="WW", to="LH"   },
                { from="WW", to="MINE" },
            },
            color = C_ORANGE,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 6 : SILVERSHARD MINES — Payload 10v10
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[6] = {
    mapFolder = "SilverShardMines",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="LAVA", name="Chariot Lave", x=130, y=290, desc="Lava Cart — 5 joueurs + healer obligatoire" },
        { id="MID",  name="Chariot Mid",  x=380, y=385, desc="Middle Cart — classes autonomes sans healer" },
        { id="TOP",  name="Chariot Top",  x=630, y=185, desc="Top Cart — JAMAIS en premier !" },
        { id="GOAL", name="Arrivée",      x=380, y=510, desc="Zone de dépôt des chariots" },
    },
    spawn = {
        alliance = { x=380, y=50 },
        horde    = { x=380, y=50 },
    },
    steps_fr = {
        {
            title      = "5 LAVA — 3 off-carts",
            desc       = "5 joueurs → LAVA (avec healer). TOUJOURS.\n3 joueurs → Middle d'abord, puis Top.\n⚠ JAMAIS Top en premier : perdre Mid = votre LAVA est en 2v3.",
            highlights = { "LAVA", "MID" },
            arrows     = {
                { from="spawn_alliance", to="LAVA" },
                { from="spawn_alliance", to="MID"  },
            },
            color = C_GREEN,
        },
        {
            title      = "Off-carts : classes autonomes",
            desc       = "Off-carts sans healer : Rogue, DH Havoc, Feral Druid, Boomkin, Augment Evoker.\n⚠ Si ennemi envoie un healer en off-carts → matchez IMMÉDIATEMENT.\nGagnez Middle → montez ensuite en Top.",
            highlights = { "MID", "TOP" },
            arrows     = { { from="MID", to="TOP" } },
            color      = C_GOLD,
        },
        {
            title      = "Plan B : tournez les rails",
            desc       = "Perdez Top → tournez les rails Top pour libérer des joueurs vers Mid.\nPerdez LAVA → tournez les rails Top pour récupérer Mid.\nAdaptez la répartition en temps réel.",
            highlights = { "TOP", "MID", "LAVA" },
            arrows     = nil,
            color      = C_ORANGE,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 7 : TEMPLE OF KOTMOGU — Orbes 10v10
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[7] = {
    mapFolder = "TempleOfKotmogu",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="N",   name="Orbe Nord",  x=380, y=100, desc="Orbe nord du temple" },
        { id="S",   name="Orbe Sud",   x=380, y=470, desc="Orbe sud du temple" },
        { id="E",   name="Orbe Est",   x=630, y=285, desc="Orbe est du temple" },
        { id="W",   name="Orbe Ouest", x=130, y=285, desc="Orbe ouest du temple" },
        { id="CTR", name="Centre",     x=380, y=285, desc="Centre du temple — ÉVITEZ avec l'orbe !" },
    },
    spawn = {
        alliance = { x=190, y=480 },
        horde    = { x=570, y=90  },
    },
    steps_fr = {
        {
            title      = "Désignez 2 porteurs",
            desc       = "Porteurs : Pres Evoker > Resto Druid > Aff Lock > Dest Lock > DH Havoc > Sub Rogue.\n⚠ JAMAIS Holy Pala, JAMAIS pure melee.\n2 porteurs max — les autres TUENT les porteurs ennemis.",
            highlights = { "N", "W" },
            arrows     = {
                { from="spawn_alliance", to="W" },
                { from="spawn_horde",    to="E" },
            },
            color = C_GREEN,
        },
        {
            title      = "Kite à l'extérieur — LoS pilliers",
            desc       = "Porteur : kite DEHORS du temple, pas au centre.\nUtilisez les PILLIERS pour briser la ligne de vue.\nN'allez au centre qu'en dominance totale.\n150 stacks ennemis + vous êtes 3 → attaquez, il tombe.",
            highlights = { "N", "S", "E", "W" },
            arrows     = nil,
            color      = C_GOLD,
        },
        {
            title      = "Healer offensif",
            desc       = "1 healer → soutient vos porteurs défensifs.\n1 healer → avance AVEC les DPS qui chassent les orbes ennemis.\nSans healer offensif : votre offense wipe et l'ennemi snowball avantage.",
            highlights = { "CTR" },
            arrows     = nil,
            color      = C_ORANGE,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 8 : DEEPWIND GORGE — Domination 15v15
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[8] = {
    mapFolder = "DeepwindGorge",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="AM",  name="Mine Alliance", x=140, y=140, desc="Alliance Mine — nord-ouest" },
        { id="MKT", name="Market",        x=380, y=285, desc="Market — node central, MAX 2 joueurs !" },
        { id="HM",  name="Mine Horde",    x=620, y=430, desc="Horde Mine — sud-est" },
        { id="SHR", name="Sanctuaire",    x=200, y=420, desc="Shrine — CD Reset Buff peut spawner ici" },
    },
    spawn = {
        alliance = { x=95,  y=475 },
        horde    = { x=665, y=100 },
    },
    steps_fr = {
        {
            title      = "Triangle + Market (2 max)",
            desc       = "Alliance : AM + Market. Horde : HM + Market.\nMarket : 1 healer tanky + 1 DPS disruptif MAXIMUM.\n3v2 avec healer prend une éternité → jouez PASSIF.\nCD Reset Buff : surveillez-le au Market ET au Sanctuaire.",
            highlights = { "AM", "MKT" },
            arrows     = {
                { from="spawn_alliance", to="AM"  },
                { from="spawn_alliance", to="MKT" },
                { from="spawn_horde",    to="HM"  },
                { from="spawn_horde",    to="MKT" },
            },
            color = C_GREEN,
        },
        {
            title      = "Rotation horizontale uniquement",
            desc       = "Rotez UNIQUEMENT sur les triangles horizontaux (votre mine ↔ Market).\nTraversée verticale = trop longue, le node sera pris avant votre arrivée.\nException : si 6+ d'un côté et 0 de l'autre → faites la traversée verticale.",
            highlights = { "AM", "MKT" },
            arrows     = {
                { from="AM",  to="MKT" },
                { from="MKT", to="HM"  },
            },
            color = C_GOLD,
        },
        {
            title      = "Contestez leur triangle",
            desc       = "Envoyez 1-2 joueurs sur leur mine pour forcer leur rotation.\nMême sans cap, ils reviennent et vous libèrent de la pression au Market.\nCD Reset Buff au Shrine : priorité absolue quand le node est contesté.",
            highlights = { "HM", "SHR" },
            arrows     = { { from="AM", to="HM" } },
            color      = C_ORANGE,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 9 : SEETHING SHORE — Nodes dynamiques 10v10
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[9] = {
    mapFolder = "SeethingShore",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="P1", name="Plateforme N",  x=380, y=90,  desc="Plateforme nord" },
        { id="P2", name="Plateforme NO", x=130, y=190, desc="Plateforme nord-ouest" },
        { id="P3", name="Plateforme NE", x=630, y=190, desc="Plateforme nord-est" },
        { id="P4", name="Plateforme O",  x=90,  y=340, desc="Plateforme ouest" },
        { id="P5", name="Plateforme E",  x=670, y=340, desc="Plateforme est" },
        { id="P6", name="Plateforme SO", x=220, y=460, desc="Plateforme sud-ouest" },
        { id="P7", name="Plateforme SE", x=540, y=460, desc="Plateforme sud-est" },
    },
    spawn = {
        alliance = { x=380, y=530 },
        horde    = { x=380, y=530 },
    },
    steps_fr = {
        {
            title      = "Nodes dynamiques — mobilité max",
            desc       = "Les nodes apparaissent et disparaissent aléatoirement sur les plateformes.\n5 joueurs → node le plus proche de votre groupe.\n3 joueurs → node secondaire.\nMobilité > fights : ne restez jamais bloqué sur un node disparu.",
            highlights = { "P1", "P2", "P3", "P4", "P5", "P6", "P7" },
            arrows     = nil,
            color      = C_GREEN,
        },
        {
            title      = "Split sur 2-3 nodes actifs",
            desc       = "Ne regroupez jamais toute l'équipe sur 1 node.\nVisez 2-3 nodes simultanément.\nClasses mobiles en off-node, healer + tank sur le node contesté.",
            highlights = { "P2", "P3", "P6" },
            arrows     = nil,
            color      = C_GOLD,
        },
        {
            title      = "Plan B",
            desc       = "Si vous perdez partout : concentrez 8-10 sur UN seul node pour le sécuriser.\nPrenez de l'élan, puis re-splitez sur les prochains nodes.",
            highlights = { "P1" },
            arrows     = nil,
            color      = C_ORANGE,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 10 : DEEPHAUL RAVINE — Payload+Cristal 10v10
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[10] = {
    mapFolder = "DeephaulRavine",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="CW",   name="Chariot Ouest", x=140, y=285, desc="Chariot côté ouest — à escorter" },
        { id="CRYS", name="Cristal",       x=380, y=285, desc="Cristal central — objectif principal" },
        { id="CE",   name="Chariot Est",   x=620, y=285, desc="Chariot côté est — à escorter" },
    },
    spawn = {
        alliance = { x=380, y=100 },
        horde    = { x=380, y=470 },
    },
    steps_fr = {
        {
            title      = "Combattez pour le cristal",
            desc       = "Matchez les chiffres sur chaque objectif.\nNe laissez jamais un objectif sans réponse adverse.\nClasses mobiles roament entre chariots et cristal.",
            highlights = { "CRYS" },
            arrows     = {
                { from="spawn_alliance", to="CRYS" },
                { from="spawn_horde",    to="CRYS" },
            },
            color = C_GREEN,
        },
        {
            title      = "Escortez les chariots",
            desc       = "3-4 joueurs par chariot, dont 1 healer.\nAdaptez en temps réel selon les positions adverses.\nNe laissez pas un chariot ennemi avancer sans contestation.",
            highlights = { "CW", "CE" },
            arrows     = nil,
            color      = C_GOLD,
        },
        {
            title      = "Plan B",
            desc       = "Perdez un chariot : abandonnez-le, regroupez au cristal.\nReprenez l'avantage central puis re-escortez vos chariots.",
            highlights = { "CRYS" },
            arrows     = {
                { from="CW",   to="CRYS" },
                { from="CE",   to="CRYS" },
            },
            color = C_ORANGE,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 11 : ALTERAC VALLEY — Rush général 40v40
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[11] = {
    mapFolder = "AlteracValley",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="DB",   name="Dun Baldar",     x=380, y=80,  desc="Base Alliance — Général Alliance ici" },
        { id="SHGY", name="GY Stonehearth", x=440, y=200, desc="Stonehearth GY — graveyard nord" },
        { id="TP",   name="Tower Point",    x=510, y=235, desc="Tower Point — tour nord à défendre" },
        { id="IBGY", name="GY Iceblood",    x=320, y=370, desc="Iceblood GY — graveyard central sud" },
        { id="IBT",  name="Iceblood Tower", x=270, y=350, desc="Iceblood Tower — tour sud" },
        { id="WFT",  name="Tour Ouest FW",  x=200, y=455, desc="Frostwolf West Tower" },
        { id="EFT",  name="Tour Est FW",    x=560, y=455, desc="Frostwolf East Tower" },
        { id="DREK", name="Drek'Thar",      x=380, y=500, desc="Général Horde — objectif final Alliance" },
    },
    spawn = {
        alliance = { x=380, y=60  },
        horde    = { x=380, y=545 },
    },
    steps_fr = {
        {
            title      = "Rush général : ignorez tout",
            desc       = "Alliance : RUSH droit vers Drek'Thar. Ne stoppez PAS aux tours.\nHorde : RUSH droit vers le Général Alliance.\nDétruire les tours donne +10% dégâts — mais le rush pur peut être plus rapide.\nObjectif : tuer le général ennemi AVANT que le vôtre tombe.",
            highlights = { "DREK" },
            arrows     = {
                { from="spawn_alliance", to="IBGY" },
                { from="IBGY",           to="DREK" },
            },
            color = C_GREEN,
        },
        {
            title      = "Sécurisez GY + tours FW",
            desc       = "Si le rush est bloqué : détruisez WFT + EFT pour affaiblir Drek'Thar.\nCapez IBGY pour avancer votre point de résurrection.\nSécurisez un GY avant le push final sur Drek'Thar.",
            highlights = { "WFT", "EFT", "IBGY" },
            arrows     = {
                { from="IBGY", to="WFT"  },
                { from="IBGY", to="EFT"  },
                { from="IBGY", to="DREK" },
            },
            color = C_GOLD,
        },
        {
            title      = "Défense de base",
            desc       = "Si l'ennemi rush votre Général : 5-10 defenders en base IMMÉDIATEMENT.\nNE LAISSEZ PAS votre général mourir.\nResto/heals restent en base, DPS les kite en sortie.",
            highlights = { "DB" },
            arrows     = nil,
            color      = C_RED,
        },
    },
    steps_en = {
        {
            title      = "General Rush — skip everything",
            desc       = "Alliance : RUSH straight to Drek'Thar. Skip towers.\nHorde : RUSH straight to Alliance General.\nGoal : kill enemy general BEFORE yours falls.",
            highlights = { "DREK" },
            arrows     = {
                { from="spawn_alliance", to="IBGY" },
                { from="IBGY",           to="DREK" },
            },
            color = C_GREEN,
        },
        {
            title      = "Secure GY + FW Towers",
            desc       = "If rush is blocked : destroy WFT + EFT to weaken Drek'Thar.\nCap IBGY to push your rez point forward.\nSecure a GY before final push.",
            highlights = { "WFT", "EFT", "IBGY" },
            arrows     = {
                { from="IBGY", to="WFT"  },
                { from="IBGY", to="EFT"  },
                { from="IBGY", to="DREK" },
            },
            color = C_GOLD,
        },
        {
            title      = "Defend your General",
            desc       = "If enemy is rushing your General : 5-10 defenders now.\nDO NOT let your General die.\nHealers stay in base, DPS kite enemies at exit.",
            highlights = { "DB" },
            arrows     = nil,
            color      = C_RED,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 12 : ISLE OF CONQUEST — Siège 40v40
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[12] = {
    mapFolder = "IsleOfConquest",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="DOCK", name="Docks",      x=130, y=285, desc="Docks — Catapultes (secondaire)" },
        { id="WKSP", name="Atelier",    x=380, y=285, desc="Workshop — Véhicules de siège (priorité !)" },
        { id="HANG", name="Hangar",     x=630, y=200, desc="Hangar — Gyrocopters, saut par-dessus les murs" },
        { id="QRY",  name="Carrière",   x=260, y=420, desc="Quarry — ressources, faible priorité" },
        { id="REF",  name="Raffinerie", x=500, y=160, desc="Refinery — ressources, faible priorité" },
        { id="AK",   name="Keep All.",  x=380, y=80,  desc="Keep Alliance — Général Alliance ici" },
        { id="HK",   name="Keep Horde", x=380, y=490, desc="Keep Horde — Général Horde ici" },
    },
    spawn = {
        alliance = { x=380, y=60  },
        horde    = { x=380, y=540 },
    },
    steps_fr = {
        {
            title      = "Workshop + Hangar EN PRIORITÉ",
            desc       = "Workshop = Véhicules de siège. CAPTUREZ-LE EN PREMIER.\nHangar = Gyrocopters qui sautent les murs = accès direct au keep ennemi.\nDocks = Catapultes. Secondaire.",
            highlights = { "WKSP", "HANG" },
            arrows     = {
                { from="spawn_alliance", to="WKSP" },
                { from="spawn_alliance", to="HANG" },
            },
            color = C_GREEN,
        },
        {
            title      = "Siège du keep ennemi",
            desc       = "Véhicules en ligne devant la porte principale du keep.\nHangar → Gyros sautent les murs pour des kills directs.\nCatapultes → bombardement des portes et walls.\nKillez les PILOTES (6× plus rapide que de détruire le véhicule).",
            highlights = { "HK" },
            arrows     = {
                { from="WKSP", to="HK" },
                { from="HANG", to="HK" },
            },
            color = C_GOLD,
        },
        {
            title      = "Défense du keep",
            desc       = "Si l'ennemi a des véhicules : 10+ defenders dans le keep.\nKillez les PILOTES, pas les véhicules (6× plus rapide).\nPaladins : Consecration dans les portes. DK : Grip les pilotes hors du keep.",
            highlights = { "AK" },
            arrows     = nil,
            color      = C_RED,
        },
    },
    steps_en = {
        {
            title      = "Workshop + Hangar FIRST",
            desc       = "Workshop = Siege Vehicles. CAPTURE IT FIRST.\nHangar = Gyrocopters that wall-hop = direct access to enemy keep.\nDocks = Catapults. Secondary.",
            highlights = { "WKSP", "HANG" },
            arrows     = {
                { from="spawn_alliance", to="WKSP" },
                { from="spawn_alliance", to="HANG" },
            },
            color = C_GREEN,
        },
        {
            title      = "Siege the enemy keep",
            desc       = "Line vehicles at the main gate.\nHangar Gyros hop walls for direct kills.\nDon't waste vehicles outside the keep.\nKill DRIVERS, not vehicles (6× faster).",
            highlights = { "HK" },
            arrows     = { { from="WKSP", to="HK" } },
            color      = C_GOLD,
        },
        {
            title      = "Defend your keep",
            desc       = "If enemy has vehicles : 10+ defenders inside keep.\nKill the DRIVERS, not the vehicles.\nPaladins : Consecration at gates. DK : Grip pilots out.",
            highlights = { "AK" },
            arrows     = nil,
            color      = C_RED,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 13 : ASHRAN — Route de la Gloire 40v40
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[13] = {
    mapFolder = "Ashran",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="SS",  name="Stormshield",    x=130, y=285, desc="Base Alliance — Stormshield Stronghold" },
        { id="EXC", name="Excavation",     x=280, y=220, desc="Excavation — artefact nord" },
        { id="EMB", name="Emberfall",      x=380, y=285, desc="Emberfall Tower — centre de la route" },
        { id="XYL", name="Xylem",          x=530, y=190, desc="Archmage Xylem Event — artefact est" },
        { id="WS",  name="Warspear",       x=630, y=285, desc="Base Horde — Warspear Stronghold" },
    },
    spawn = {
        alliance = { x=100, y=285 },
        horde    = { x=660, y=285 },
    },
    steps_fr = {
        {
            title      = "Contrôlez la route centrale",
            desc       = "Ashran = combat sur la Road of Glory (route principale).\nGagnez le push central pour avancer dans la base ennemie.\nGagnez 6+ événements sur la map pour débloquer les buffs.",
            highlights = { "EMB" },
            arrows     = {
                { from="spawn_alliance", to="EMB" },
                { from="spawn_horde",    to="EMB" },
            },
            color = C_GREEN,
        },
        {
            title      = "Événements et artefacts",
            desc       = "Événements parallèles : 5-8 joueurs sur chaque.\nArtefacts gagnés → buffs de faction.\nCoordonnez en raid chat : 'Xylem au nord — 5 là-bas'.",
            highlights = { "EXC", "XYL" },
            arrows     = nil,
            color      = C_GOLD,
        },
        {
            title      = "Push final en base",
            desc       = "Avec 10+ frags de victoire : rush toute l'équipe dans la base ennemie.\nFocus le général en premier.\nFonctionnez en masse — ne vous éparpillez pas.",
            highlights = { "WS" },
            arrows     = { { from="EMB", to="WS" } },
            color      = C_RED,
        },
    },
    steps_en = {
        {
            title      = "Control the Glory Road",
            desc       = "Ashran = combat on the Road of Glory.\nWin the center push to advance into enemy base.\nWin 6+ events to unlock faction buffs.",
            highlights = { "EMB" },
            arrows     = {
                { from="spawn_alliance", to="EMB" },
                { from="spawn_horde",    to="EMB" },
            },
            color = C_GREEN,
        },
        {
            title      = "Events and Artifacts",
            desc       = "Side events : send 5-8 players to each.\nWin artifacts → faction buffs.\nCoordinate in raid chat.",
            highlights = { "EXC", "XYL" },
            arrows     = nil,
            color      = C_GOLD,
        },
        {
            title      = "Final Base Push",
            desc       = "10+ kill frags : rush everyone into enemy base.\nFocus the General first. Stay together.",
            highlights = { "WS" },
            arrows     = { { from="EMB", to="WS" } },
            color      = C_RED,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 14 : WINTERGRASP — Attaque/Défense 40v40
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[14] = {
    mapFolder = "Wintergrasp",
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="WS1",  name="Atelier NO",  x=130, y=380, desc="Workshop NW — véhicules de siège" },
        { id="WS2",  name="Atelier NE",  x=630, y=380, desc="Workshop NE — véhicules de siège" },
        { id="WS3",  name="Atelier S",   x=380, y=490, desc="Workshop S — véhicules de siège" },
        { id="TWR1", name="Tour NO",     x=130, y=240, desc="Tower NW — +10% dégâts par tour détruite" },
        { id="TWR2", name="Tour NE",     x=630, y=240, desc="Tower NE — +10% dégâts par tour détruite" },
        { id="KEEP", name="Forteresse",  x=380, y=150, desc="Wintergrasp Keep — objectif final attaquant" },
    },
    spawn = {
        alliance = { x=380, y=530 },
        horde    = { x=380, y=80  },
    },
    steps_fr = {
        {
            title      = "Attaquants : ateliers + tours",
            desc       = "Capturez les 3 ateliers pour obtenir vos véhicules de siège.\nDétruisez TWR1 + TWR2 : +10% dégâts chacune sur le keep.\nAvec 3 véhicules + 2 tours détruites → la forteresse tombe rapidement.",
            highlights = { "WS1", "WS2", "WS3" },
            arrows     = {
                { from="spawn_alliance", to="WS1" },
                { from="spawn_alliance", to="WS2" },
                { from="spawn_alliance", to="WS3" },
            },
            color = C_GREEN,
        },
        {
            title      = "Siège de la forteresse",
            desc       = "Véhicules en ligne devant la porte principale.\nDétruisez les murs avec vos catapultes/demolishers.\nInfanterie : chargez une fois le mur tombé.\nKillez les PILOTES ennemis, pas les véhicules.",
            highlights = { "KEEP", "TWR1", "TWR2" },
            arrows     = {
                { from="WS1",  to="KEEP" },
                { from="WS2",  to="KEEP" },
                { from="TWR1", to="KEEP" },
            },
            color = C_RED,
        },
        {
            title      = "Défenseurs",
            desc       = "Focus sur les véhicules ennemis.\nKillez les PILOTES (6× plus rapide que détruire le véhicule).\nGardez au moins 15 personnes dans le keep en permanence.",
            highlights = { "KEEP" },
            arrows     = nil,
            color      = C_ORANGE,
        },
    },
    steps_en = {
        {
            title      = "Attackers: Workshops + Towers",
            desc       = "Capture 3 workshops for siege vehicles.\nDestroy TWR1 + TWR2 : +10% damage to keep each.\nWith vehicles + towers down → keep falls fast.",
            highlights = { "WS1", "WS2", "WS3" },
            arrows     = {
                { from="spawn_alliance", to="WS1" },
                { from="spawn_alliance", to="WS2" },
            },
            color = C_GREEN,
        },
        {
            title      = "Siege the Fortress",
            desc       = "Line vehicles at the main gate.\nBombard keep walls with catapults/demolishers.\nInfantry charges once wall is breached.\nKill enemy DRIVERS, not vehicles.",
            highlights = { "KEEP" },
            arrows     = {
                { from="WS1", to="KEEP" },
                { from="WS2", to="KEEP" },
            },
            color = C_RED,
        },
        {
            title      = "Defenders",
            desc       = "Focus enemy vehicles.\nKill the DRIVERS (6× faster than destroying the vehicle).\nKeep 15+ players inside the keep at all times.",
            highlights = { "KEEP" },
            arrows     = nil,
            color      = C_ORANGE,
        },
    },
}

-- ─────────────────────────────────────────────────────────────────────────────
-- BG 15 : SLAYER'S RISE — 3 phases 40v40 (Midnight)
-- ─────────────────────────────────────────────────────────────────────────────
MBGA_BGMapData[15] = {
    mapFolder = "",   -- Nouveau BG Midnight — tiles custom à ajouter après calibration in-game
    canvasW = 760, canvasH = 570,
    nodes = {
        { id="P1", name="Phase 1",      x=380, y=140, desc="Première phase — objectif initial" },
        { id="P2", name="Phase 2",      x=380, y=285, desc="Deuxième phase — mid-game" },
        { id="P3", name="Phase finale", x=380, y=430, desc="Troisième phase — objectif final" },
    },
    spawn = {
        alliance = { x=130, y=285 },
        horde    = { x=630, y=285 },
    },
    steps_fr = {
        {
            title      = "Phase 1",
            desc       = "Nouveau BG Midnight — stratégie à définir après les premières parties.\nObjectif principal : compléter la phase 1 avant l'ennemi.",
            highlights = { "P1" },
            arrows     = {
                { from="spawn_alliance", to="P1" },
                { from="spawn_horde",    to="P1" },
            },
            color = C_GREEN,
        },
        {
            title      = "Phase 2",
            desc       = "Transition vers la phase 2.\nAdaptez votre composition selon les besoins de la phase.",
            highlights = { "P2" },
            arrows     = { { from="P1", to="P2" } },
            color      = C_GOLD,
        },
        {
            title      = "Phase finale",
            desc       = "All-in sur l'objectif final.\nNe laissez pas l'ennemi finir avant vous.",
            highlights = { "P3" },
            arrows     = { { from="P2", to="P3" } },
            color      = C_RED,
        },
    },
    steps_en = {
        {
            title      = "Phase 1",
            desc       = "New Midnight BG — strategy TBD after first games.\nMain objective : complete phase 1 before the enemy.",
            highlights = { "P1" },
            arrows     = {
                { from="spawn_alliance", to="P1" },
                { from="spawn_horde",    to="P1" },
            },
            color = C_GREEN,
        },
        {
            title      = "Phase 2",
            desc       = "Transition to phase 2. Adapt your composition.",
            highlights = { "P2" },
            arrows     = { { from="P1", to="P2" } },
            color      = C_GOLD,
        },
        {
            title      = "Final Phase",
            desc       = "All-in on the final objective.\nDon't let the enemy finish before you.",
            highlights = { "P3" },
            arrows     = { { from="P2", to="P3" } },
            color      = C_RED,
        },
    },
}
