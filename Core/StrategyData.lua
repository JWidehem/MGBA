-- Core/StrategyData.lua — Source de vérité pour toutes les stratégies
-- Données issues exclusivement de MBGA-Strat.md
-- Structure par BG : id, nameKey, type, strat { fr = {...}, en = {...} }
-- Les textes utilisent \n pour les sauts de ligne dans l'UI

MBGA_BGs = {}

-- ─── BGs NORMAUX (10v10 / 15v15) ─────────────────────────────────────────────

MBGA_BGs[1] = {
    id      = "WSG",
    nameKey = "BG_WSG",
    isEpic  = false,
    format  = "CTF 10v10",
    strat = {
        fr = {
            winCondition = "Rapporter 3 drapeaux ennemis dans votre base avant l'adversaire.",
            criticalRule = "Ne surchargez JAMAIS la défense. 2-3 défenseurs max. 6+ défenseurs = l'offense ennemie fonce sans opposition.",
            roles =
                "• 1-2 FC : classe mobile/résistante (Pres Evoker, Resto Druide, Resto Shaman)\n" ..
                "• 3-4 ESCORT : 1-2 heals + peelers (DK grip, Warrior Shockwave, Frost Mage roots, Ret Paladin Freedom)\n" ..
                "• 2-3 OFFENSE : stealthes + burst (Rogue, MM Hunter, Boomkin Incarn)\n" ..
                "• 1-2 DÉFENSE BASE : Rogue stealth + 1 classe long range\n" ..
                "⚠️ Holy Paladin = JAMAIS FC (CDs neutralisés avec le flag)",
            planA =
                "1. Stealther prend le drapeau en furtif, le garde sans scorer\n" ..
                "2. 2 heals construisent le momentum les 30 premières secondes\n" ..
                "3. Passe sécurisée : vérifiez BGE (stealther ennemi en embuscade ?)\n" ..
                "4. DK/Warrior/Frost Mage bloquent les rampes contre les FC ennemis\n" ..
                "5. WSG : défense solide dans les rampes. TP : priorité à l'offense, moins de défense.",
            planB =
                "Score 0-2 retard : 8 joueurs en défense totale, 2 Rogues ninja le flag ennemi quand leur base est dégarnie.",
        },
    },
}

MBGA_BGs[2] = {
    id      = "TP",
    nameKey = "BG_TP",
    isEpic  = false,
    format  = "CTF 10v10",
    strat = {
        fr = {
            winCondition = "Rapporter 3 drapeaux ennemis dans votre base. Twin Peaks = carte ouverte, la course gagne.",
            criticalRule = "Alliance : stoppez les knockbackers sur la falaise extérieure — Stun/Silence avant qu'ils éjectent votre FC dans le vide.",
            roles =
                "• 1-2 FC : classe mobile (Pres Evoker prioritaire sur carte ouverte)\n" ..
                "• 2 ESCORT offensifs : Ret Paladin (Freedom + BoP + LoH), DK\n" ..
                "• 3-4 OFFENSE : très important sur TP (carte ouverte = moins de défense)\n" ..
                "• 1-2 DÉFENSE allégée : Pres + Ret peut suffire en défense",
            planA =
                "1. Priorité absolue à la vitesse de course — si vous gagnez la course, vous gagnez\n" ..
                "2. Certaines équipes jouent 6v2 offensif : Pres + Ret en seule défense, 6 en offense\n" ..
                "3. Évitez le fight au milieu — contournez vers leur base\n" ..
                "4. Sur la falaise : positionnez votre FC à l'écart des bords, knockbackers en couverture",
            planB =
                "Score 0-2 : mêmes FC sur la route + tout le monde en ESCORT serré. La survie du FC prime.",
        },
    },
}

MBGA_BGs[3] = {
    id      = "AB",
    nameKey = "BG_AB",
    isEpic  = false,
    format  = "Domination 15v15",
    strat = {
        fr = {
            winCondition = "Première équipe à 1600 ressources. Tenir 3+ nodes = tick victorieux. Contester leurs nodes vaut autant que défendre les vôtres.",
            criticalRule = "BLACKSMITH : 2 joueurs MAXIMUM. 3+ joueurs = catastrophe — vos autres nodes tombent en sous-effectif. Un 3v2 avec healer spin indéfiniment.",
            roles =
                "• BLACKSMITH : 1 healer tanky (Prêtre/Paladin) + 1 DPS disruptif — jouez PASSIF\n" ..
                "• LUMBERMILL : 1 healer avec mobilité (Pres Evoker/Mistweaver) + 1 DPS knockback (Ele Shaman, Mage)\n" ..
                "• MINES : Ret Paladin + burst depuis stealth — utilisez TOUS VOS CDs au 1er fight\n" ..
                "• FARM/STABLES : 1-2 joueurs + renforts rotants depuis l'axe horizontal\n" ..
                "⚠️ Warrior/mêlée sans self-heal → pas aux Mines sans healer",
            planA =
                "1. Trois groupes capent leur triangle simultanément au départ\n" ..
                "2. Mines : Ret Paladin pop tous ses CDs d'entrée (Bubble → BoP → LoH = 3 immunités)\n" ..
                "3. LM : knockback défensif depuis la falaise — l'ennemi ne peut pas burst si risque d'éjection\n" ..
                "4. Technique 'Fake BS push' : avancez vers BS → ennemi quitte LM → rebroussez → prenez LM\n" ..
                "5. Contestez leurs nodes avec un Ret ou Rogue pour forcer leur rotation",
            planB =
                "1-node ou 0-node : tout le monde au BS, puis extension progressive vers Farm ou Mine.",
        },
    },
}

MBGA_BGs[4] = {
    id      = "EOTS",
    nameKey = "BG_EOTS",
    isEpic  = false,
    format  = "Dom+CTF 15v15",
    strat = {
        fr = {
            winCondition = "Première équipe à 1500 ressources. 2 nodes + 0 drapeau = WIN CONDITION parfaite — l'ennemi ne marque AUCUN point même s'il vous tue.",
            criticalRule = "Ne capturez JAMAIS le drapeau si vous avez 2 nodes. DROPEZ-le (clic droit buff → retirer) pour reforcer l'ennemi à aller le chercher et quitter vos nodes.",
            roles =
                "• 2 groupes de 6-7 sur les nodes de votre côté respectif\n" ..
                "• 1 healer par node — se répartir immédiatement si le jeu bascule en mode CTF\n" ..
                "• Flag runner : uniquement si vous avez 3 nodes ou score à 1850+ pts",
            planA =
                "1. Capez 2 nodes côté allié immédiatement — ne luttez pas pour les 2 nodes opposés\n" ..
                "2. Avec 2 nodes sécurisés : dropez le drapeau si quelqu'un l'a — interdiction absolue de capper\n" ..
                "3. Passez en mode 'spin défensif' : CC, survivre, tick tranquille\n" ..
                "4. Timing de fin : avec 3 tours à 1850 pts → capez pour victoire instantanée\n" ..
                "5. Combattez DANS le radius du flag de la tour (pas à côté) — les points comptent seulement dans le radius",
            planB =
                "Perte des 2 nodes : passez en mode CTF total — 1 healer par node actif, utilisez toute votre mobilité.",
        },
    },
}

MBGA_BGs[5] = {
    id      = "BFG",
    nameKey = "BG_BFG",
    isEpic  = false,
    format  = "Domination 15v15",
    strat = {
        fr = {
            winCondition = "Première équipe à contrôler 2 des 3 bases (Lighthouse, Waterworks, Mine). Lighthouse et Mine = bases triangulaires, WW = objectif central.",
            criticalRule = "Ghosting Dangereux : ne cappez leur base QUE si vous pouvez la tenir. Ghosting raté = down 1 joueur + leur rotation reprend + double peine.",
            roles =
                "• WATERWORKS : team fight principal, spin le flag en permanence\n" ..
                "• LIGHTHOUSE/MINE floater : 1 DPS mobile (DH Havoc, Boomkin, Augment Evoker) — matcher sans sortir de healer\n" ..
                "• Règle match numbers : 2 DPS ennemis → 1 DPS mobile (pas un healer !), 3+ ennemis → 1 healer + 1 DPS",
            planA =
                "1. Capez 2 bases immédiatement (LH + Mine OU WW + une autre)\n" ..
                "2. Prenez Shadow Sight (près du WW) — révèle les ennemis en stealth, pinguez leur position\n" ..
                "3. WW : interrompez les sorts ennemis, stoppez les drinks, ciblez les heals\n" ..
                "4. Matchez leurs envoyés avec la classe adaptée — Augment Evoker ideal floater",
            planB =
                "Perte de 2 bases : focus WW en masse (7v6), tenez-le, puis extension vers la base la plus proche.",
        },
    },
}

MBGA_BGs[6] = {
    id      = "SSM",
    nameKey = "BG_SSM",
    isEpic  = false,
    format  = "Payload 10v10",
    strat = {
        fr = {
            winCondition = "Premier à livrer les 3 chariots (Lava, Middle, Top) à destination. Chaque chariot complété vaut des points. Lava = priorité absolue.",
            criticalRule = "NE JAMAIS commencer en Top. Si vous gagnez Middle, vous pouvez aller en Top. L'inverse = votre equipe Lava est en 2v3 et perd tout.",
            roles =
                "• LAVA (5) : healer obligatoire. Classes résistantes : DK Sang, Ret Paladin, Prot Warrior, Vengeance DH, Healer\n" ..
                "• OFF-CARTS (3) : Middle puis Top — Classes solo sans healer : Rogue, DH Havoc, Feral Druide, Boomkin, Augment Evoker\n" ..
                "• Si l'ennemi envoie un healer off-carts → matchez avec un healer off-carts aussi",
            planA =
                "1. 5 joueurs résistants partent en Lava avec le healer\n" ..
                "2. 3 classes solo vont en Middle d'abord — sécurisez Middle AVANT d'aller en Top\n" ..
                "3. Une fois Middle sécurisé, 1-2 peuvent monter en Top\n" ..
                "4. Si l'ennemi envoie un healer en off-carts : matchez immédiatement",
            planB =
                "Perte des off-carts : tournez les rails du Top pour libérer des joueurs. Perdez les Middles → tournez les rails du Top.",
        },
    },
}

MBGA_BGs[7] = {
    id      = "TK",
    nameKey = "BG_TK",
    isEpic  = false,
    format  = "Orbes 10v10",
    strat = {
        fr = {
            winCondition = "Première équipe à 1500 points. Points/s selon position des porteurs : centre (max) > intérieur > extérieur. Kite à l'extérieur = survie maximale.",
            criticalRule = "⚠️ Holy Paladin et Guerrier pur mêlée = JAMAIS porteurs d'orbe. Kiter HORS du temple bat toujours le strategy 'aller au centre' tant que votre équipe domine.",
            roles =
                "Hiérarchie porteurs d'orbe :\n" ..
                "1. Preservation Evoker (self-heal en mouvement + souffle + Hover)\n" ..
                "2. Resto Druide (HoTs en courant, Dash, Forme Ours)\n" ..
                "3. Démoniste Affliction (Drain Life passif, Port de secours LoS)\n" ..
                "4. Démoniste Destruction (Port LoS, Sacrifice + self-heal)\n" ..
                "5. Démon Hunter Havoc (Blur + Darkness + mobilité extrême)\n" ..
                "6. Sub Rogue (Shadow Dance derrière un pilier)",
            planA =
                "1. Prenez vos 2 orbes côté allié — NE JAMAIS prendre les 4 (personne pour tuer leurs porteurs)\n" ..
                "2. Porteurs : kitez à l'EXTÉRIEUR du temple entre les piliers pour LoS\n" ..
                "3. 1 healer suit les porteurs défensifs, 1 healer avance avec les DPS offensifs\n" ..
                "4. Technique Warlock : port → drop l'orbe derrière un mur → burst → reprend via port\n" ..
                "5. À 150+ stacks sur un porteur ennemi : 3 sur lui immédiatement",
            planB =
                "Perte de 2 orbes : défense totale de l'extérieur du temple, ciblez les porteurs ennemis à faibles stacks.",
        },
    },
}

MBGA_BGs[8] = {
    id      = "DWG",
    nameKey = "BG_DWG",
    isEpic  = false,
    format  = "Domination 15v15",
    strat = {
        fr = {
            winCondition = "Première équipe à 1500 ressources. 5 nodes : votre triangle + Market central + leur triangle. Tenir 3+ nodes = win.",
            criticalRule = "MARKET : 2 joueurs MAXIMUM (1 healer tanky + 1 DPS disruptif). 3+ joueurs = vos bases extérieures tombent en cascade. Rotation HORIZONTALE uniquement.",
            roles =
                "• MARKET : 1 healer tanky (Mistweaver/Resto Shaman) + 1 DPS disruptif (DK, Ret)\n" ..
                "• Bases alliées : 1-2 par node, rotations horizontales uniquement\n" ..
                "• Floater Ret/Rogue : conteste leurs bases pour forcer leur rotation",
            planA =
                "1. Capez votre triangle, 2 joueurs vont au Market\n" ..
                "2. ROTATION HORIZONTALE : votre base ↔ Market ↔ bases adjacentes uniquement\n" ..
                "3. Surveillez le CD Reset Buff (Market + fontaine Shrine) — reset de tous les CDs + haste\n" ..
                "4. Enviez un Ret/Rogue contester leurs bases pour forcer leur rotation\n" ..
                "5. 6+ de votre côté vs 0 de l'autre → seul cas où traversée verticale justifiée",
            planB =
                "Perte du triangle : tout le monde au Market, puis extension vers la base la plus proche.",
        },
    },
}

MBGA_BGs[9] = {
    id      = "SS",
    nameKey = "BG_SS",
    isEpic  = false,
    format  = "Nodes dynamiques 10v10",
    strat = {
        fr = {
            winCondition = "Première équipe à 1500 ressources. Les nodes apparaissent et disparaissent dynamiquement sur la map — suivez les marqueurs carte.",
            criticalRule = "Les nodes ennemis trop défendus = passez au suivant. Abandonner un node = correct si 3+ ennemis le défendent.",
            roles =
                "• 6 joueurs mobiles : suivent les nodes dès apparition (marqueur carte)\n" ..
                "• 2 joueurs : harcèlent les nodes ennemis pour briser le tick\n" ..
                "• 2 joueurs : défensent les nodes déjà tenus",
            planA =
                "1. 6 joueurs mobiles suivent les nodes dès qu'ils apparaissent sur la carte\n" ..
                "2. 2 joueurs harcèlent les nodes ennemis pour briser leur tick\n" ..
                "3. 2 joueurs défendent les nodes déjà capturés\n" ..
                "4. Abandonner un node trop défendu : CORRECT — allez au node suivant",
            planB =
                "Retard de 2+ nodes : tout le monde en mode harassment sur leurs nodes pour briser le tick — reconstituez vos nodes en parallèle.",
        },
    },
}

MBGA_BGs[10] = {
    id      = "DR",
    nameKey = "BG_DR",
    isEpic  = false,
    format  = "Payload+Cristal 10v10",
    strat = {
        fr = {
            winCondition = "Première équipe à 5 points (chariots + orbe central). Full wipe au milieu = game quasi terminée.",
            criticalRule = "Match Numbers STRICTEMENT : 1 ennemi va dans votre chariot = envoyez 1 personne, PAS 6. Surengager = perdre le fight du milieu = l'ennemi prend tout.",
            roles =
                "• Fight du milieu : majorité de l'équipe — healer(s) obligatoire(s)\n" ..
                "• Defender chariot : 1 personne matche 1 ennemi, ni plus ni moins\n" ..
                "• Orbe du milieu : 2 joueurs tanky + 2 heals (mode Market stall)\n" ..
                "• Base sitter : se REPOSITIONNE avant que le nouveau chariot spawne — pas après",
            planA =
                "1. Maintenez le fight du milieu — c'est le pivot de toute la map\n" ..
                "2. Matchez exactement leurs envoyés dans vos chariots (1 pour 1)\n" ..
                "3. Base sitter : repositionnez-vous AVANT le spawn du nouveau chariot\n" ..
                "4. Un caster rapide peut finir quelqu'un dans le chariot et revenir sans manquer le mid",
            planB =
                "En retard d'un orbe : 8 joueurs au milieu, ciblez le healer ennemi → CC → wipe → cap orbe. Quelqu'un clique l'orbe PENDANT que les DPS finissent les kills. Si vraiment down : 3 tanky+2 heals dans LEUR chariot, tous CDs pop.",
        },
    },
}

-- ─── BGs ÉPIQUES (40v40) — FR + EN ───────────────────────────────────────────

MBGA_BGs[11] = {
    id      = "AV",
    nameKey = "BG_AV",
    isEpic  = true,
    format  = "Rush 40v40",
    strat = {
        fr = {
            winCondition = "Tuer le général ennemi (Horde : Drek'Thar / Alliance : Vanndar). AV est une COURSE symétrique — votre offense gagne, pas votre défense.",
            criticalRule = "NE JAMAIS s'arrêter pour fight au milieu. Laissez Snowfall GY NEUTRE (y capper = Alliance respawn au milieu = turtle catastrophique).",
            roles =
                "• Push principal (25-30) : ne s'arrêtent pas, capent GYs en chemin\n" ..
                "• Brûleurs de tours (5-8) : en parallèle du push — chaque tour −75 renforts sur le général\n" ..
                "• 2 joueurs min restent dans chaque bunker/tour capé (furtifs ennemis peuvent recapper)\n" ..
                "• Rogue/Druide en avant-garde : cap furtif du 1er bunker ennemi pendant que les 30 autres fight",
            planA =
                "HORDE : GY Stonehearth → Balinda → Iceblood Tower → Frostwolf Relief Hut → Tours × 4 → Drek\n" ..
                "ALLIANCE : IBGY → Galvangar → Iceblood Tower → Relief Hut → Frostwolf Towers × 4 → Drek\n" ..
                "Règle : n'attaquez pas le général avec moins de 3 tours brûlées\n" ..
                "Si chokepoint défendu : contournez monté vers le Frostwolf Relief Hut directement",
            planB =
                "Horde bloquée : 5-8 joueurs vers Frostwolf Relief Hut + brûlez les tours Est/Ouest depuis le RH. Alliance bloquée : même stratégie, contournez le chokepoint monté.",
        },
        en = {
            winCondition = "Kill the enemy general (Horde: Drek'Thar / Alliance: Vanndar). AV is a RACE — your offense wins, your defense doesn't.",
            criticalRule = "NEVER stop to fight in the middle. Leave Snowfall GY NEUTRAL (capping it = Alliance respawns at mid = catastrophic turtle).",
            roles =
                "• Main push (25-30): never stop, cap GYs along the way\n" ..
                "• Tower burners (5-8): parallel to push — each tower destroyed = −75 general reinforcements\n" ..
                "• 2+ players stay in each capped bunker/tower (enemy stealthers can recapture)\n" ..
                "• Rogue/Druid point: stealth-cap first enemy bunker while 30 others fight Balinda/Galvangar",
            planA =
                "HORDE: Stonehearth GY → Balinda → Iceblood Tower → Frostwolf Relief Hut → Towers × 4 → Drek\n" ..
                "ALLIANCE: IBGY → Galvangar → Iceblood Tower → Relief Hut → Frostwolf Towers × 4 → Drek\n" ..
                "Rule: don't attack the general with fewer than 3 towers burned\n" ..
                "If chokepoint is defended: ride around it directly to Frostwolf Relief Hut",
            planB =
                "Horde stuck: 5-8 players to Frostwolf Relief Hut + burn East/West towers from RH. Alliance stuck: same, ride around the chokepoint.",
        },
    },
}

MBGA_BGs[12] = {
    id      = "IOC",
    nameKey = "BG_IOC",
    isEpic  = true,
    format  = "Siège 40v40",
    strat = {
        fr = {
            winCondition = "Détruire les portes du Keep ennemi et tuer leur général. Map ASYMÉTRIQUE : Horde = Hangar (airship), Alliance = Docks (Glaive Throwers).",
            criticalRule = "Horde : Glaive Throwers Alliance depuis la péninsule Ouest = HORS de portée de vos canons. Détruisez-les EN PRIORITÉ ABSOLUE dès qu'ils apparaissent.",
            roles =
                "• HORDE : Hangar (équipe airship 8-10) + Workshop (Demolishers vers porte Est)\n" ..
                "• ALLIANCE : Docks + Glaive Throwers sur péninsule Ouest (3-4 protecteurs obligatoires)\n" ..
                "• Technique 'Back Door' : parachutez via airship/catapulte dans le Keep ennemi → ramassez Huge Seaforium Bombs → brèche de l'intérieur",
            planA =
                "HORDE : Hangar → Airship → Porte EST du Keep Alliance + Workshop → Demolishers soutien\n" ..
                "ALLIANCE : Docks → Glaive Throwers (péninsule Ouest, hors portée canons Horde) → brèche\n" ..
                "Back Door : 3-5 joueurs catapultés/parachutés dans le Keep ennemi → Huge Seaforium Bombs\n" ..
                "Objectif PvE : tuer général après brèche",
            planB =
                "Horde perd Hangar : 8 joueurs le reprennent immédiatement. Workshop seul = Demolishers porte Ouest. Alliance perd Docks : 10 joueurs reprennent Docks → priorité absolue.",
        },
        en = {
            winCondition = "Destroy enemy Keep doors and kill their general. ASYMMETRIC map: Horde = Hangar (airship), Alliance = Docks (Glaive Throwers).",
            criticalRule = "Horde: Alliance Glaive Throwers from the West peninsula are OUT OF RANGE of your cannons. Destroy them as an ABSOLUTE PRIORITY the moment they appear.",
            roles =
                "• HORDE: Hangar team (8-10, airship) + Workshop (Demolishers to East gate)\n" ..
                "• ALLIANCE: Docks + Glaive Throwers on West peninsula (3-4 protectors mandatory)\n" ..
                "• 'Back Door' technique: parachute/catapult into enemy Keep → grab Huge Seaforium Bombs → breach from inside",
            planA =
                "HORDE: Hangar → Airship → East gate of Alliance Keep + Workshop → Demolisher support\n" ..
                "ALLIANCE: Docks → Glaive Throwers (West peninsula, out of Horde cannon range) → breach\n" ..
                "Back Door: 3-5 players catapulted/parachuted into enemy Keep → Huge Seaforium Bombs\n" ..
                "PvE objective: kill general after breach",
            planB =
                "Horde loses Hangar: 8 players retake immediately. Workshop alone = Demolishers West gate. Alliance loses Docks: 10 players retake immediately — absolute priority.",
        },
    },
}

MBGA_BGs[13] = {
    id      = "ASHRAN",
    nameKey = "BG_ASHRAN",
    isEpic  = true,
    format  = "Route de la Gloire 40v40",
    strat = {
        fr = {
            winCondition = "L'équipe qui invoque l'Élémental EN PREMIER (Fangraal ou Kronus) gagne quasi systématiquement la Route de la Gloire.",
            criticalRule = "Ignorer les events (AOA, BR, AE) = l'ennemi accumule les fragments 2× plus vite → invoque l'Élémental avant vous → gagne la Route.",
            roles =
                "• Route principale (25) : push + fight direct\n" ..
                "• Events en rotation (10) : AOA / Brute's Rise / Excavation → 250 Conquest + fragments\n" ..
                "• Backdoor Rogues (3-4) : Ring of Conquest en furtif → attaque base ennemie par derrière\n" ..
                "• Porteur de l'Ancient Artifact (1) : TOUT le monde le protège s'il est obtenu",
            planA =
                "1. Split en 3 groupes : Route principale + Events + Backdoor Rogues\n" ..
                "2. TRICK du Ring of Conquest : chargez les ogres du Ring → ils agro l'ennemi qui arrive (avantage positionnel)\n" ..
                "3. Farmez les fragments → turnez à votre faction → invoquez l'Élémental\n" ..
                "4. Élémental invoqué → poussez la Route GROUPÉS avec lui (absorbe 90% des dégâts)\n" ..
                "5. Turnez 10 fragments à l'alchimiste de faction → potions de raid",
            planB =
                "Ring of Conquest perdu : NE PAS retenter frontalement. Farmez les events en masse → invoquez l'Élémental avant eux → revenez sur le Ring avec lui.",
        },
        en = {
            winCondition = "The team that summons the Elemental FIRST (Fangraal or Kronus) almost always wins the Glory Road.",
            criticalRule = "Ignoring events (AOA, BR, AE) = enemy accumulates fragments 2× faster → summons Elemental before you → wins the Road.",
            roles =
                "• Main Road (25): push + direct fight\n" ..
                "• Rotating events (10): AOA / Brute's Rise / Excavation → 250 Conquest + fragments\n" ..
                "• Backdoor Rogues (3-4): stealth through Ring of Conquest → attack enemy base from behind\n" ..
                "• Ancient Artifact carrier (1): EVERYONE protects them if obtained",
            planA =
                "1. Split into 3 groups: Main Road + Events + Backdoor Rogues\n" ..
                "2. Ring of Conquest TRICK: aggro the Ring ogres onto incoming enemies (positional advantage)\n" ..
                "3. Farm fragments → turn in to faction → summon Elemental\n" ..
                "4. Elemental summoned → push the Road GROUPED with it (absorbs 90% of damage)\n" ..
                "5. Turn in 10 fragments to faction alchemist → raid potions",
            planB =
                "Ring of Conquest lost: DO NOT retry frontally. Mass farm events → summon Elemental before them → return to Ring with it.",
        },
    },
}

MBGA_BGs[14] = {
    id      = "WG",
    nameKey = "BG_WG",
    isEpic  = true,
    format  = "Attaque/Défense 40v40",
    strat = {
        fr = {
            winCondition = "ATTAQUE : détruire la Relique dans le Fortress (30 min). DÉFENSE : empêcher l'attaque pendant 30 min. La Quick Punch gagne : 10-16 Siege Engines groupés sur UN mur = inarrêtable.",
            criticalRule = "ATTAQUE : attendez 10-16 Siege Engines avant de pousser. 3-4 engins seuls = tués facilement. En masse = inarrêtables. La DIVERSION vers l'Est/Sud est obligatoire.",
            roles =
                "• ATTAQUE — Masse principale (20-25) : Siege Engines + fantassins de protection devant\n" ..
                "• ATTAQUE — Diversion (5-8) : attaque tours Est/Sud pour diviser la défense\n" ..
                "• DÉFENSE — Canonniers (6) : 1 joueur par canon, focus UNIQUEMENT sur les véhicules\n" ..
                "• DÉFENSE — Demolishers défensifs (best choice), Catapultes anti-joueurs",
            planA =
                "ATTAQUE : attendez 10-16 Siege Engines → diversion Est/Sud (5-8 joueurs) → masse principale OUEST\n" ..
                "Fantassins marchent DEVANT les Siege Engines pour les protéger\n" ..
                "Une brèche → continuez par le MÊME trou (ne changez pas de mur)\n\n" ..
                "DÉFENSE : 6 canons sur les véhicules uniquement (pas les joueurs à pied)\n" ..
                "Murs = régénèrent après ~10 min si l'ennemi ne pousse plus\n" ..
                "Mur percé → retraitez cour intérieure → canons intérieurs",
            planB =
                "ATTAQUE bloquée : masse (25+) sur UN Workshop → overpower. 5 furtifs ninja le 2ème Workshop simultanément. DÉFENSE percée : cour intérieure + 5-6 joueurs sur la Relique pour interrompre en continu.",
        },
        en = {
            winCondition = "ATTACK: destroy the Relic inside the Fortress (30 min). DEFENSE: prevent the attack for 30 min. Quick Punch wins: 10-16 grouped Siege Engines on ONE wall = unstoppable.",
            criticalRule = "ATTACK: wait for 10-16 Siege Engines before pushing. 3-4 engines alone = easily killed. Massed = unstoppable. A DIVERSION to the East/South is mandatory.",
            roles =
                "• ATTACK — Main mass (20-25): Siege Engines + infantry walking in front for protection\n" ..
                "• ATTACK — Diversion (5-8): attack East/South towers to split the defense\n" ..
                "• DEFENSE — Gunners (6): 1 player per cannon, focus ONLY on vehicles\n" ..
                "• DEFENSE — Defensive Demolishers (best), Catapults for anti-player",
            planA =
                "ATTACK: wait for 10-16 Siege Engines → East/South diversion (5-8 players) → main mass pushes WEST\n" ..
                "Infantry walks IN FRONT of Siege Engines to protect them\n" ..
                "A breach → keep pushing through the SAME hole (don't switch walls)\n\n" ..
                "DEFENSE: 6 cannons on vehicles only (not infantry)\n" ..
                "Walls REGENERATE after ~10 min if enemy stops pushing\n" ..
                "Wall breached → retreat inner courtyard → interior cannons",
            planB =
                "ATTACK stuck: mass (25+) on ONE Workshop → overpower. 5 stealthers ninja the 2nd Workshop simultaneously. DEFENSE breached: inner courtyard + 5-6 players on the Relic for continuous interrupts.",
        },
    },
}

MBGA_BGs[15] = {
    id      = "SR",
    nameKey = "BG_SR",
    isEpic  = true,
    format  = "3 phases 40v40",
    strat = {
        fr = {
            winCondition = "Tuer Domanaar après avoir progressé en 3 phases. NE PAS s'arrêter pour kill — les objectifs font gagner. Phase 3 : désactivez les Ethereal Defenses OBLIGATOIREMENT.",
            criticalRule = "RÈGLE ABSOLUE : désactivez les Ethereal Defenses en Phase 3 (interagissez avec les structures mécaniques). Sans ça = push bloqué même si vous dominez tous les fights.",
            roles =
                "• Push team (20) : rush les objectifs Phase 1→2→3 sans s'arrêter, classes mobiles\n" ..
                "• Response/Défense (5) : défendent la Shenzar Refinery et les objectifs capturés (tanks + 1 heal)\n" ..
                "• Objectif latéral (6-8) : recrutent les boss PNJ (Griefspine Ultradon, Kronus) — ils suivent le raid\n" ..
                "• Stall team (4-5) : bloquent le GY ennemi pendant le boss final (2-3 tanks + 1 heal + mass CC)",
            planA =
                "PHASE 1 — Shenzar Refinery :\n" ..
                "Push team (20) rush la Refinery → tuez les 3 gardes → capez\n" ..
                "Ramassez les Ethereal Manacells → portez vers les outposts ennemis → détruisez\n\n" ..
                "PHASE 2 — Path of Predation :\n" ..
                "ARRIVEZ GROUPÉS (demi-équipe trop tôt = combat en sous-effectif = défaite)\n" ..
                "Contrôlez le Path → ouvre les lanes vers la base ennemie\n\n" ..
                "PHASE 3 — Bastion + Domanaar :\n" ..
                "Désactivez les Ethereal Defenses (structures mécaniques)\n" ..
                "Bastion capé → portails + GY avancé + buff raid\n" ..
                "COMMIT TOTAL sur Domanaar — la stall team gère les renforts ennemis",
            planB =
                "Refinery perdue : push team continue vers le Path sans s'arrêter. Objectif latéral : priorisez les boss recrutables pour compenser le désavantage. Stall team : indispensable même si la Refinery est perdue.",
        },
        en = {
            winCondition = "Kill Domanaar after progressing through 3 phases. DON'T stop to fight — objectives win games. Phase 3: disabling Ethereal Defenses is MANDATORY.",
            criticalRule = "ABSOLUTE RULE: disable the Ethereal Defenses in Phase 3 (interact with the mechanical structures). Without this = push blocked even if you dominate every fight.",
            roles =
                "• Push team (20): rush Phase 1→2→3 objectives without stopping, mobile classes\n" ..
                "• Response/Defense (5): defend Shenzar Refinery and captured objectives (tanks + 1 heal)\n" ..
                "• Side objective team (6-8): recruit PNJ bosses (Griefspine Ultradon, Kronus) — they follow the raid\n" ..
                "• Stall team (4-5): block enemy GY during final boss (2-3 tanks + 1 heal + mass CC)",
            planA =
                "PHASE 1 — Shenzar Refinery:\n" ..
                "Push team (20) rushes the Refinery → kill 3 guards → cap\n" ..
                "Pick up Ethereal Manacells → carry to enemy outposts → destroy\n\n" ..
                "PHASE 2 — Path of Predation:\n" ..
                "ARRIVE GROUPED (half the team arriving early = understaffed fight = defeat)\n" ..
                "Control the Path → opens lanes to the enemy base\n\n" ..
                "PHASE 3 — Bastion + Domanaar:\n" ..
                "Disable Ethereal Defenses (mechanical structures)\n" ..
                "Bastion captured → portals + advanced GY + raid buff\n" ..
                "FULL COMMIT on Domanaar — stall team handles enemy reinforcements",
            planB =
                "Refinery lost: push team continues to the Path without stopping. Side objective team: prioritize recruitable bosses to compensate the disadvantage. Stall team: still mandatory even if Refinery is lost.",
        },
    },
}
