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
            winCondition = "Volez le drapeau dans la salle ennemie et ramenez-le 3 fois dans votre base. Premier a 3 captures gagne.",
            criticalRule = "Maximum 2-3 joueurs en defense de votre base. Si toute l'equipe defend, personne n'attaque et vous perdez. L'attaque gagne ce BG.",
            roles =
                "• 1-2 PORTEURS DE DRAPEAU : classe resistante (Druide Soin, Evoker, Chaman Soin)\n" ..
                "• 2-3 ESCORTES : ralentissent ceux qui chassent le porteur (DK, Mage Givre, Ret Paladin)\n" ..
                "• 2-3 ATTAQUANTS : entrent dans leur base pour voler le drapeau (Rogue, DH Havoc)\n" ..
                "• 1-2 DEFENSEURS gardent votre drapeau\n" ..
                "JAMAIS Paladin Sacre porteur : ses boucliers se desactivent quand il porte le drapeau",
            planA =
                "1. Les furtifs (Rogues) entrent discritement et volent leur drapeau\n" ..
                "2. Le porteur court vers votre base avec les escortes autour de lui\n" ..
                "3. Bloquez les couloirs (rampes et tunnels lateraux) pour ralentir leurs porteurs\n" ..
                "4. Votre drapeau est vole ? Ne ramenez PAS le leur avant de l'avoir recupere",
            planB =
                "Score 0-2 de retard : 8 joueurs gardent votre drapeau, 2 furtifs tentent un vol surprise quand leur base est vide.",
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
            winCondition = "Volez le drapeau ennemi et ramenez-le 3 fois dans votre base. Carte ouverte : la vitesse prime sur la defense.",
            criticalRule = "Attention aux bords de falaise. L'ennemi va essayer de pousser votre porteur de drapeau dans le vide. Gardez votre porteur loin des precipices.",
            roles =
                "• 1-2 PORTEURS : classe tres mobile (Evoker ideal sur cette grande carte ouverte)\n" ..
                "• 2 ESCORTES : Ret Paladin (peut rendre son porteur invulnerable + soins), DK\n" ..
                "• 3-4 ATTAQUANTS : la vitesse est cle sur cette carte, foncez sur leur base\n" ..
                "• 1-2 DEFENSEURS (leger : 2 joueurs suffisent ici contrairement a d'autres BG)",
            planA =
                "1. Vitesse absolue : prenez leur drapeau AVANT eux et courez, vous gagnez la course\n" ..
                "2. Contournez les combats au milieu, allez directement a leur base\n" ..
                "3. Porteur sur la falaise : restez loin des bords, escortes positionnees devant\n" ..
                "4. Option aggressive : 1-2 defenseurs seulement, 6 joueurs en attaque",
            planB =
                "Retard 0-2 : serrez l'escorte autour du porteur, sa survie prime sur tout le reste.",
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
            winCondition = "5 bases a capturer : Ecuries, Ferme, Moulin, Mines, Forges. Tenir 3 bases en meme temps fait marquer des points. Premier a 1600 points gagne.",
            criticalRule = "Les Forges (au centre de la carte) : MAXIMUM 2 joueurs. Y envoyer 5-6 joueurs = vos autres bases tombent faute de defenseurs. 2 joueurs bien places suffisent.",
            roles =
                "• 3 groupes de 4-5 joueurs sur les 3 bases de votre cote\n" ..
                "• 1 healer par base minimum\n" ..
                "• Ret Paladin ou Rogue : harcele les bases ennemies pour forcer leurs joueurs a bouger",
            planA =
                "1. Depart : 3 groupes capturent les 3 bases les plus proches (votre triangle selon votre faction)\n" ..
                "2. 3-4 joueurs par base suffit, ne surchargez pas une seule base\n" ..
                "3. Forges (base au centre) : envoyez 2 joueurs max, jouez defensif\n" ..
                "4. Attaquez UNE base ennemie a la fois avec un groupe entier, ne vous dispersez pas",
            planB =
                "Vous tenez 1 base ou moins : tout le monde aux Forges, puis etendez vers les bases adjacentes.",
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
            winCondition = "4 tours dans les angles + 1 cristal au centre. Chaque tour tenue rapporte des points. Le cristal donne des points bonus si ramene dans une tour. Premier a 1500 points gagne.",
            criticalRule = "Vous tenez 2 tours ? NE PRENEZ PAS le cristal central. Il ne sert a rien et distrait votre equipe. Restez sur vos 2 tours et laissez-les se battre pour le cristal.",
            roles =
                "• 2 groupes de 6-7 joueurs chacun sur vos 2 tours\n" ..
                "• 1 healer par tour minimum\n" ..
                "• Cristal : seulement si vous avez 3 tours OU si vous etes a 1850+ points (pour finir vite)",
            planA =
                "1. 2 groupes capturent les 2 tours de votre cote (pas besoin de traverser la carte)\n" ..
                "2. Tenez ces 2 tours : c'est tout ce qu'il faut faire pour gagner\n" ..
                "3. Cristal central : ignorez-le si vous avez 2 tours\n" ..
                "4. Combattez DANS le cercle de la tour (pas a cote) pour que vos kills comptent pour la capture",
            planB =
                "Vous perdez vos 2 tours : tout le monde prend le cristal et le ramene dans la tour la plus proche.",
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
            winCondition = "3 bases a capturer : Phare (gauche), Station de Pompage (centre), Mine (droite). Tenez 2 des 3 en meme temps. Premier a 2000 points gagne.",
            criticalRule = "N'attaquez PAS une base avec 3+ ennemis dedans. Trop risque. Allez harasser une autre base pour forcer les ennemis a se deplacer, puis revenez.",
            roles =
                "• Station de Pompage (centre) : combat principal, 1 healer minimum\n" ..
                "• 1 joueur mobile harcele les bases ennemies (oblige l'ennemi a bouger pour defendre)\n" ..
                "• Matchez leurs effectifs : 2 ennemis sur une base = envoyez 2 joueurs, pas 6",
            planA =
                "1. Capturez 2 bases au depart (Phare + Mine ou Station + une autre)\n" ..
                "2. Cherchez l'orbe Shadow Sight (pres de la Station) : il revele les ennemis en furtif\n" ..
                "3. Station : interrompez les sorts ennemis, ciblez les healers en premier\n" ..
                "4. Envoyez exactement autant de joueurs qu'eux sur chaque base (ni plus, ni moins)",
            planB =
                "Vous tenez 0 base : tout le monde a la Station de Pompage, puis etendez vers la base adjacente la plus facile.",
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
            winCondition = "3 chariots a escorter jusqu'a destination (Lave en bas, Milieu, Haut). Restez pres du chariot pour le faire avancer. Premier a livrer les 3 gagne.",
            criticalRule = "Commencez TOUJOURS par le chariot du bas (Lave). Si personne n'est a Lave, votre equipe meurt en boucle dans la lave. Ne commencez JAMAIS par le chariot du Haut.",
            roles =
                "• LAVE (5 joueurs) : 1 healer obligatoire. Classes resistantes : DK, Ret Paladin, Prot Warrior\n" ..
                "• MILIEU puis HAUT (3 joueurs) : classes qui survivent seules (Rogue, DH Havoc, Druide Feral)\n" ..
                "• Si l'ennemi envoie un healer sur ses chariots : envoyez-en un aussi",
            planA =
                "1. 5 joueurs resistants + 1 healer vont immediatement au chariot Lave (en bas)\n" ..
                "2. 3 classes autonomes vont au chariot du Milieu d'abord\n" ..
                "3. Milieu bien avance -> 1-2 joueurs montent au chariot du Haut\n" ..
                "4. Lave en danger : envoyez un joueur en renfort depuis un autre chariot",
            planB =
                "Vous perdez le Milieu et le Haut : concentrez tout sur Lave, c'est le plus important.",
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
            winCondition = "4 orbes dans les angles du temple. Portez-les. Plus vous restez pres du centre, plus vous marquez de points vite. Premier a 1500 points gagne.",
            criticalRule = "Prenez SEULEMENT 2 orbes (votre cote). Si vous prenez les 4, personne ne peut chasser leurs porteurs. 2 orbes bien proteges valent toujours mieux que 4 indefensables.",
            roles =
                "Meilleurs porteurs (resistants en mouvement) : Druide Soin, Evoker, Demoniste\n" ..
                "MAUVAIS porteurs : Paladin Sacre, Guerrier (ils ont besoin de rester immobiles)\n" ..
                "4 joueurs chassent activement les porteurs ennemis pour les tuer",
            planA =
                "1. Prenez vos 2 orbes (votre cote), laissez les 2 autres\n" ..
                "2. Porteurs : restez derriere les piliers du temple (ils bloquent les tirs)\n" ..
                "3. Fuyez vers l'exterieur si vous etes chasses (vous survivez plus longtemps)\n" ..
                "4. Porteur ennemi avec beaucoup de stacks de douleur (icone rouge) : 3 joueurs sur lui",
            planB =
                "Vous perdez vos 2 orbes : defense a l'exterieur du temple, tuez leurs porteurs les moins proteges.",
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
            winCondition = "5 bases dont le Marche au centre. Tenez 3 bases en meme temps. Meme principe qu'Arathi. Premier a 1500 points gagne.",
            criticalRule = "Le Marche (base au centre) : MAXIMUM 2 joueurs. Envoyer plus = vos autres bases tombent. Rotations gauche-centre-droite SEULEMENT, sans traverser tout le BG.",
            roles =
                "• Marche (centre) : 1 healer tanky + 1 DPS\n" ..
                "• Bases alliees : 1-2 joueurs chacune\n" ..
                "• Ret Paladin / Rogue : harcele leurs bases pour les forcer a bouger",
            planA =
                "1. Capturez votre triangle, envoyez 2 joueurs au Marche\n" ..
                "2. Rotation HORIZONTALE uniquement : votre base -> Marche -> votre autre base\n" ..
                "3. Buff de reset (au Marche et a la fontaine) : recharge TOUS vos cooldowns + bonus de vitesse\n" ..
                "4. Harcelez 1-2 de leurs bases pour les forcer a quitter leurs positions",
            planB =
                "Vous perdez vos bases : tout le monde au Marche, puis etendez vers les bases les plus proches.",
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
            winCondition = "Des rochers de cristal apparaissent aleatoirement sur la carte (bips sur la minimap). Capturez-les pour marquer des points. Ils disparaissent et bougent en permanence. Premier a 1500 points gagne.",
            criticalRule = "Regardez la minimap en permanence. Les rochers bougent. Aller a un endroit vide = perdre du temps. Node ennemi avec 3+ defenseurs : passez au suivant.",
            roles =
                "• 6 joueurs mobiles : vont aux nouveaux rochers des qu'ils apparaissent sur la minimap\n" ..
                "• 2 joueurs : harcelent les nodes ennemis pour briser leur capture en cours\n" ..
                "• 2 joueurs : gardent les rochers deja captures",
            planA =
                "1. 6 joueurs mobiles vont aux rochers des qu'ils apparaissent (regardez la minimap constamment)\n" ..
                "2. 2 joueurs harcelent les nodes ennemis pour interrompre leur capture\n" ..
                "3. 2 joueurs protegent vos nodes deja pris\n" ..
                "4. Node avec 3+ ennemis que vous n'arrivez pas a briser : passez au rotcher suivant",
            planB =
                "Retard de 2+ nodes : tout le monde harcele leurs nodes pour briser le tick, capturez les libres en meme temps.",
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
            winCondition = "2 chariots (un par equipe) a escorter + 1 orbe au centre. Chaque livraison de chariot ou capture d'orbe = 1 point. Premier a 5 points gagne.",
            criticalRule = "Matchez exactement leurs effectifs : 1 ennemi dans votre chariot = envoyez 1 joueur seulement. Envoyer 6 contre 1 = vous perdez le milieu et l'orbe.",
            roles =
                "• Majorite de l'equipe tient le combat du milieu (c'est le pivot)\n" ..
                "• 1 joueur defend votre chariot contre exactement 1 ennemi\n" ..
                "• Orbe central : 2 joueurs resistants + healers\n" ..
                "• Un caster peut tuer l'ennemi dans le chariot et revenir au milieu rapidement",
            planA =
                "1. Gardez le combat du milieu : tout se gagne ou se perd ici\n" ..
                "2. 1 joueur defend votre chariot contre 1 ennemi seulement\n" ..
                "3. Repositionnez-vous AVANT que le nouveau chariot spawne (pas apres)\n" ..
                "4. Tuez le healer ennemi en priorite -> prenez l'orbe pendant les kills",
            planB =
                "En retard d'un orbe : 8 joueurs au milieu, tuez leur healer d'abord, puis prenez l'orbe. Si tres en retard : 3 joueurs resistants + 2 healers s'infiltrent dans LEUR chariot avec tous les cooldowns.",
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
            winCondition = "Tuez le general ennemi au fond de la carte.\nHorde : Vanndar est dans la forteresse au NORD. Alliance : Drek'Thar est dans la forteresse au SUD.\nC'est une COURSE : foncez directement, ne vous arretez pas pour combattre.",
            criticalRule = "Ne capturez PAS le cimetiere de Snowfall (le cimetiere au milieu de la carte). Si vous le prenez, les ennemis reapparaissent au centre et bloquent votre avancee vers le general. Passez-le en courant.",
            roles =
                "• 25-30 joueurs : foncent vers le general sans s'arreter\n" ..
                "• 5-8 joueurs : detruisent les tours en chemin (chaque tour detruite = le general ennemi a moins de vie)\n" ..
                "• Furtifs en avant : capturent le 1er bunker ennemi pendant que les autres combattent les sous-officiers\n" ..
                "• Capturez les cimetieres en chemin : ca raccourcit vos trajets de resurrection apres mort",
            planA =
                "HORDE : rush vers le nord -> capturez les cimetieres en chemin -> detruisez les 4 tours -> tuez Vanndar\n" ..
                "ALLIANCE : rush vers le sud -> meme trajet -> tuez Drek'Thar\n" ..
                "REGLE : n'attaquez pas le general avec moins de 3 tours detruites (il a encore trop de vie)\n" ..
                "BLOQUES : contournez a cheval par les bords de la carte, ne forcez pas un passage frontal",
            planB =
                "Bloques au milieu : 5-8 joueurs contournent par les cotes et brulent les tours. Ne tentez pas de passer en frontal.",
        },
        en = {
            winCondition = "Kill the enemy general deep in the map.\nHorde: Vanndar is in the fortress to the NORTH. Alliance: Drek'Thar is in the fortress to the SOUTH.\nThis is a RACE: rush straight there, do not stop to fight.",
            criticalRule = "Do NOT capture Snowfall graveyard (the graveyard in the middle of the map). Taking it makes enemies respawn at the center and blocks your path to the general.",
            roles =
                "• 25-30 players: rush the general without stopping\n" ..
                "• 5-8 players: destroy towers en route (each tower destroyed = enemy general has fewer hit points)\n" ..
                "• Stealthers up front: stealth-cap first enemy bunker while others fight the sub-bosses\n" ..
                "• Capture graveyards along the way: shortens respawn trips after death",
            planA =
                "HORDE: rush north -> cap graveyards on the way -> burn 4 towers -> kill Vanndar\n" ..
                "ALLIANCE: rush south -> same route -> kill Drek'Thar\n" ..
                "RULE: don't attack the general with fewer than 3 towers burned (too much health remaining)\n" ..
                "BLOCKED: ride around the flanks, don't charge into the enemy mass",
            planB =
                "Blocked in the middle: 5-8 players ride around the flanks and burn towers. Don't try the frontal route.",
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
            winCondition = "Detruisez les portes de la forteresse ennemie avec des vehicules de siege, puis tuez leur general a l'interieur. Carte asymetrique : chaque faction a sa propre strategie.",
            criticalRule = "HORDE : les catapultes a lames Alliance (sur la peninsule Ouest) sont HORS portee de vos canons. Detruisez-les en priorite absolue des qu'elles apparaissent.",
            roles =
                "• HORDE : equipe Hangar (8-10) controlent le vaisseau aerien + equipe Artisanat construit les vehicules de siege\n" ..
                "• ALLIANCE : equipe Docks + construisent des catapultes a lames (3-4 protecteurs obligatoires pres des catapultes)\n" ..
                "• Porte Derobee : 3-5 joueurs se parachutent dans le fortin ennemi -> trouvent les Huge Seaforium Bombs -> font exploser les portes de l'interieur",
            planA =
                "HORDE : prenez le Hangar -> vaisseau aerien -> attaquez la porte Est du fortin Alliance + vehicules depuis l'Artisanat\n" ..
                "ALLIANCE : prenez les Docks -> catapultes a lames (peninsule Ouest, hors portee Horde) -> percez\n" ..
                "PORTE DEROBEE : 3-5 joueurs parachutes dans le fortin ennemi -> Huge Seaforium Bombs -> percez de l'interieur\n" ..
                "Objectif final : tuez le general apres la breche",
            planB =
                "Horde perd le Hangar : 8 joueurs le reprennent immediatement. Alliance perd les Docks : 10 joueurs, priorite absolue.",
        },
        en = {
            winCondition = "Destroy the enemy Keep's gates with siege vehicles, then kill their general inside. Asymmetric map: each faction has a different strategy.",
            criticalRule = "HORDE: Alliance Glaive Throwers from the West peninsula are OUT OF RANGE of your cannons. Destroy them as ABSOLUTE PRIORITY the moment they appear.",
            roles =
                "• HORDE: Hangar team (8-10, control airship) + Workshop team (builds siege vehicles to East gate)\n" ..
                "• ALLIANCE: Docks team + Glaive Thrower builders (3-4 protectors mandatory near the Glaive Throwers)\n" ..
                "• Back Door: 3-5 players parachuted into enemy Keep -> grab Huge Seaforium Bombs -> breach from inside",
            planA =
                "HORDE: take Hangar -> airship -> attack Alliance Keep East gate + Workshop builds siege vehicles\n" ..
                "ALLIANCE: take Docks -> Glaive Throwers (West peninsula, out of Horde cannon range) -> breach\n" ..
                "BACK DOOR: 3-5 players parachuted into enemy Keep -> Huge Seaforium Bombs -> breach from inside\n" ..
                "Final: kill general after breach",
            planB =
                "Horde loses Hangar: 8 players retake immediately. Alliance loses Docks: 10 players, absolute priority.",
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
            winCondition = "Combattez sur la Route de la Gloire (route principale). L'equipe qui invoque son Elemental de faction en premier gagne presque toujours.",
            criticalRule = "Ne neglegez PAS les evenements speciaux sur les cotes (Colisee des Anciens, Tour, Excavation). Les ignorer = l'ennemi accumule les fragments 2 fois plus vite et invoque son elemental avant vous.",
            roles =
                "• Route principale (25 joueurs) : push et combat direct\n" ..
                "• Evenements sur les cotes (10 joueurs) : Colisee des Anciens / Tour / Excavation -> fragments + Conquest\n" ..
                "• Furtifs (3-4) : infiltrent la base ennemie par derriere via l'Anneau de Conquest\n" ..
                "• Porteur de l'Artefact Ancestral : toute l'equipe le protege s'il l'obtient",
            planA =
                "1. Splittez en 3 groupes : Route + Evenements + Furtifs\n" ..
                "2. Farmez les fragments des evenements -> remettez-les a l'alchimiste de votre faction\n" ..
                "3. Elemental invoque -> poussez la route EN GROUPE avec lui (il absorbe la majorite des degats)\n" ..
                "4. Ogres de l'Anneau : aggro-les sur les ennemis qui arrivent (avantage positionnel)",
            planB =
                "Vous perdez l'Anneau de Conquest : ne reessayez pas frontalement. Farmez les evenements -> invoquez l'elemental -> revenez avec lui.",
        },
        en = {
            winCondition = "Fight on the Glory Road (central road). The team that summons their faction Elemental first almost always wins.",
            criticalRule = "Do NOT neglect the side events (Ancient Coliseum, Tower, Excavation). Ignoring them means the enemy collects fragments 2x faster and summons their Elemental before you.",
            roles =
                "• Main Road (25 players): push and direct combat\n" ..
                "• Side events (10 players): Ancient Coliseum / Tower / Excavation -> fragments + Conquest\n" ..
                "• Stealthers (3-4): infiltrate enemy base from behind through the Ring of Conquest\n" ..
                "• Ancient Artifact carrier: the whole team protects them if obtained",
            planA =
                "1. Split into 3 groups: Road + Events + Stealthers\n" ..
                "2. Farm event fragments -> turn in to faction alchemist\n" ..
                "3. Elemental summoned -> push the road GROUPED with it (absorbs most incoming damage)\n" ..
                "4. Ring ogres: aggro them onto incoming enemies for positional advantage",
            planB =
                "You lose the Ring: don't retry frontally. Mass farm events -> summon Elemental first -> return with it.",
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
            winCondition = "ATTAQUANTS : detruisez les murs de la forteresse avec des vehicules de siege, puis la Relique a l'interieur. Vous avez 30 minutes.\nDEFENSEURS : empechez-les pendant 30 minutes.",
            criticalRule = "ATTAQUE : n'avancez pas avec moins de 10 vehicules de siege. 3-4 seuls = elimines facilement. Une masse de 10+ sur UN SEUL mur = quasiment inarretable.",
            roles =
                "• ATTAQUE : 20-25 joueurs suivent les vehicules (l'infanterie marche DEVANT pour les proteger des canons)\n" ..
                "• ATTAQUE Diversion (5-8) : attaquent les tours Est/Sud pour diviser les defenseurs\n" ..
                "• DEFENSE Canonniers (6) : 1 par canon, visez UNIQUEMENT les vehicules (pas les joueurs a pied)\n" ..
                "• DEFENSE : Demolisseurs defensifs sont le meilleur vehicule de defense",
            planA =
                "ATTAQUE : attendez 10-16 vehicules -> diversion Est/Sud (5-8 joueurs) -> masse principale sur le mur OUEST\n" ..
                "Infanterie marche DEVANT les vehicules pour les proteger\n" ..
                "Une breche ouverte -> continuez DANS LE MEME TROU (ne changez pas de mur)\n\n" ..
                "DEFENSE : canons vises vehicules uniquement\n" ..
                "Murs se regenerent apres environ 10 minutes si l'ennemi arrete de pousser\n" ..
                "Mur perce -> retraitez dans la cour interieure, utilisez les canons interieurs",
            planB =
                "ATTAQUE bloquee : 25+ sur UN seul Artisanat -> overpower, 5 furtifs ninja le 2eme simultanement.\nDEFENSE percee : cour interieure + 5-6 joueurs sur la Relique pour l'interrompre en continu.",
        },
        en = {
            winCondition = "ATTACK: destroy the Relic inside the Fortress (30 min). DEFENSE: prevent the attack for 30 min. Quick Punch wins: 10-16 grouped Siege Engines on ONE wall = unstoppable.",
            criticalRule = "ATTACK: wait for 10-16 Siege Engines before pushing. 3-4 engines alone = easily killed. Massed = unstoppable. A DIVERSION to the East/South is mandatory.",
            roles =
                "• ATTACK (20-25 players): escort vehicles (infantry walks IN FRONT to shield them from cannons)\n" ..
                "• ATTACK Diversion (5-8): attack East/South towers to split the defense\n" ..
                "• DEFENSE Gunners (6): 1 per cannon, target ONLY vehicles (not infantry)\n" ..
                "• DEFENSE: Demolishers are the best defensive vehicle choice",
            planA =
                "ATTACK: wait for 10-16 vehicles -> East/South diversion (5-8 players) -> main mass on WEST wall\n" ..
                "Infantry IN FRONT of vehicles to shield them\n" ..
                "Wall breached -> keep pushing THROUGH THE SAME HOLE (don't switch walls)\n\n" ..
                "DEFENSE: cannons on vehicles only\n" ..
                "Walls regenerate after ~10 min if enemy stops pushing\n" ..
                "Wall breached -> retreat to inner courtyard, use interior cannons",
            planB =
                "ATTACK stuck: 25+ on ONE Workshop -> overpower, 5 stealthers ninja the 2nd simultaneously.\nDEFENSE breached: inner courtyard + 5-6 players interrupt the Relic continuously.",
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
            winCondition = "Progressez en 3 phases pour atteindre et tuer Domanaar (le boss final). Capturez les objectifs de chaque phase avant de passer a la suivante.",
            criticalRule = "Phase 3 OBLIGATOIRE : desactivez les Defenses Etheriques (structures mecaniques brillantes sur la carte) avant d'attaquer Domanaar. Sans ca, votre rush est completement bloque.",
            roles =
                "• Equipe Rush (20) : classes mobiles, rush Phase 1 -> 2 -> 3 sans s'arreter\n" ..
                "• Equipe Defense (5) : tanks + 1 healer, protegent la Raffinerie et les objectifs captures\n" ..
                "• Equipe Laterale (6-8) : recrutent les boss recrues sur les cotes (ils rejoignent et renforcent le raid)\n" ..
                "• Equipe Stall (4-5) : bloquent le point de respawn ennemi pendant le boss final",
            planA =
                "PHASE 1 - Raffinerie de Shenzar :\n" ..
                "Equipe Rush -> tuez 3 gardes -> capturez\n" ..
                "Ramassez les Cellules Etheriques -> portez-les aux avant-postes ennemis -> detruisez\n\n" ..
                "PHASE 2 - Sentier de la Predation :\n" ..
                "Arrivez GROUPES (moitie trop tot = combat en sous-effectif = defaite)\n\n" ..
                "PHASE 3 - Bastion + Domanaar :\n" ..
                "Desactivez les Defenses Etheriques (structures brillantes)\n" ..
                "Capturez le Bastion -> portails + respawn avance + buff raid\n" ..
                "COMMIT TOTAL sur Domanaar",
            planB =
                "Raffinerie perdue : continuez vers le Sentier sans vous arreter. Equipe Laterale : priorisez les boss recrues. Equipe Stall : obligatoire meme si Raffinerie perdue.",
        },
        en = {
            winCondition = "Progress through 3 phases to reach and kill Domanaar (final boss). Capture each phase's objectives before moving on.",
            criticalRule = "Phase 3 MANDATORY: disable the Ethereal Defenses (bright mechanical structures on the map) before attacking Domanaar. Without this, your push is completely blocked.",
            roles =
                "• Rush team (20): mobile classes, rush Phase 1 -> 2 -> 3 without stopping\n" ..
                "• Defense team (5): tanks + 1 healer, protect Refinery and captured objectives\n" ..
                "• Side team (6-8): recruit side bosses (they join and reinforce the raid)\n" ..
                "• Stall team (4-5): block enemy respawn point during the final boss",
            planA =
                "PHASE 1 - Shenzar Refinery:\n" ..
                "Rush team -> kill 3 guards -> capture\n" ..
                "Pick up Ethereal Manacells -> carry to enemy outposts -> destroy\n\n" ..
                "PHASE 2 - Path of Predation:\n" ..
                "Arrive GROUPED (half arriving early = understaffed fight = defeat)\n\n" ..
                "PHASE 3 - Bastion + Domanaar:\n" ..
                "Disable Ethereal Defenses (bright structures on the map)\n" ..
                "Capture Bastion -> portals + respawn point + raid buff\n" ..
                "FULL COMMIT on Domanaar",
            planB =
                "Refinery lost: continue to Path without stopping. Side team: prioritize recruitable bosses. Stall team: mandatory even if Refinery is lost.",
        },
    },
}
