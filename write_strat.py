"""Script temporaire pour écrire les fichiers Lua proprement en UTF-8."""

lua = r"""-- Core/StrategyData.lua — Source de vérité pour toutes les stratégies
-- Structure par BG : id, nameKey, isEpic, format, strat { fr = {...}, en = {...} }
-- Champs : objective, planA (string), planB, avoid (table), roles (table de chips)

MBGA_BGs = {}

-- ─── BGs NORMAUX (10v10 / 15v15) ─────────────────────────────────────────────

MBGA_BGs[1] = {
    id      = "WSG",
    nameKey = "BG_WSG",
    isEpic  = false,
    format  = "CTF 10v10",
    strat = {
        fr = {
            objective = "Marque 3 flags. Le plus important, c'est faire survivre ton FC pendant que l'offense cree l'ouverture.",
            planA =
                "1. Prends un FC mobile et resistant.\n" ..
                "2. Mets 3-4 en escort, 2-3 en offense, 1-2 en defense base.\n" ..
                "3. Le FC doit survivre seul au debut, puis la team le rejoint pour securiser la course.",
            planB =
                "Si vous etes a 0-2, passe en defense totale de base et envoie 2 rogues ninja le flag adverse quand leur base se vide.",
            avoid = {
                "Holy Paladin FC (ses boucliers sont desactives quand il porte le flag).",
                "Surcharger la defense.",
                "Faire une passe de flag sans checker le BGE.",
            },
            roles = { "FC mobile", "escort peel", "offense stealth", "offense burst", "2 defenseurs" },
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
            objective = "Marque avant l'ennemi. Ici, la vitesse offensive compte encore plus que sur WSG.",
            planA =
                "1. Joue plus offensif que WSG. Garde un FC fort, mais investis davantage dans l'attaque.\n" ..
                "2. Twin Peaks est plus ouvert : si tu gagnes la course, tu gagnes souvent la game.\n" ..
                "3. Porteur sur la falaise : restez loin des bords, escortes positionnees devant.",
            planB =
                "A 0-2, verrouille ta base et force un ninja flag quand l'equipe ennemie surpush.",
            avoid = {
                "Surdéfendre comme sur WSG.",
                "Ignorer les knockbacks sur la falaise cote Alliance.",
                "Perdre du temps en petits fights.",
            },
            roles = { "FC mobile", "offense rapide", "2 defenseurs", "classes anti-knockback" },
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
            objective = "Tiens 3 bases stables. Les nodes gagnent la partie, pas les kills.",
            planA =
                "1. Ouvre fort sur 3 points cles et securise-les immediatement.\n" ..
                "2. Match numbers : envoie seulement le nombre necessaire pour defendre ou recap.\n" ..
                "3. Joue la rotation : si un node est trop defencu, bouge vite vers le prochain point faible.",
            planB =
                "Si vous perdez le tempo, stoppez les pushes inutiles. Reprenez une base isolee, puis stabilisez a 2-3 nodes au lieu de foncer en boucle au Blacksmith.",
            avoid = {
                "Envoyer 3+ joueurs au Blacksmith.",
                "Jouer seulement votre triangle.",
                "Garder ses CDs au premier fight Mines.",
            },
            roles = { "2 defense solides", "roamers mobiles", "1 shot caller map", "spin class", "healer resistant" },
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
            objective = "Le vrai plan gagnant, c'est souvent 2 bases + ne pas cap le drapeau.",
            planA =
                "1. Prends 2 nodes. Si vous les tenez, ne cappe jamais le flag : drop-le pour le renvoyer au milieu.\n" ..
                "2. Ca oblige l'ennemi a sortir de ses positions pour le reprendre.\n" ..
                "3. En fin de partie, garde le flag pour le cap final au bon timing.",
            planB =
                "Si la game devient chaotique, abandonne la logique 'notre cote / leur cote' et joue uniquement le prochain node faible.",
            avoid = {
                "Capper le flag alors que 2 bases suffisent deja.",
                "Fight hors du radius de cap.",
                "Capper trop tot en fin de partie.",
            },
            roles = { "1 heal par node", "FC temporaire", "classes tres mobiles" },
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
            objective = "Tiens 2 bases et gagne les matchups exacts, pas plus.",
            planA =
                "1. Au Waterworks, spin en continu.\n" ..
                "2. Si l'ennemi envoie 2 DPS sur ta base, reponds avec 1 DPS mobile adapte, pas un healer retire du teamfight.\n" ..
                "3. Utilise Shadow Sight pour tracker les stealths et eviter les ninjas gratuits.",
            planB =
                "Si une base tombe, ne ghost pas au hasard : regroupe-toi pour reprendre proprement ou cree un avantage numerique au WW.",
            avoid = {
                "Sortir un healer du WW pour matcher 2 DPS.",
                "Ghost rate.",
                "Oublier de ping le Rogue stealth.",
            },
            roles = { "floater mobile", "defenseur anti-stealth", "teamfight WW", "shotcaller map" },
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
            objective = "Gagne le chariot principal et controle les off-carts sans surinvestir.",
            planA =
                "1. 5 joueurs sur Lava avec heal.\n" ..
                "2. 3 sur les off-carts : d'abord Middle puis Top. N'ouvre jamais direct Top.\n" ..
                "3. Les off-carts doivent etre joues par des classes qui survivent sans heal.\n" ..
                "4. Si l'ennemi met un healer off-cart, matche immediatement avec un healer aussi.",
            planB =
                "Si tu perds les off-carts, tourne les rails Top. Si tu perds Lava, fais pareil pour recuperer plus de Middles.",
            avoid = {
                "Start Top direct.",
                "Envoyer une classe fragile seule sur off-cart.",
                "Ignorer un healer ennemi off-cart.",
            },
            roles = { "core Lava", "solos resistants off-cart", "heal flexible" },
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
            objective = "Prends les orbes avec les bons porteurs et fais kite a l'exterieur.",
            planA =
                "1. Donne les orbes aux meilleurs porteurs seulement.\n" ..
                "2. Kite a l'exterieur du temple, utilise les piliers.\n" ..
                "3. 1 healer en soutien defensif, l'autre accompagne l'offense qui chasse les porteurs ennemis.",
            planB =
                "Si vous perdez le controle, laisse les mauvais porteurs ne pas prendre d'orbe. 3 joueurs tombent vite un porteur ennemi avec de gros stacks.",
            avoid = {
                "Holy Paladin ou warrior pur melee porteur.",
                "Aller au centre avec de gros stacks.",
                "Mettre les 2 heals en mode pure defense.",
            },
            roles = { "porteur premium", "healer offensif", "chasseurs de porteurs", "classes LoS" },
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
            objective = "Tiens ton triangle horizontal et force les rotations ennemies.",
            planA =
                "1. Market = 2 joueurs max comme le Blacksmith a AB.\n" ..
                "2. Conteste leurs nodes pour creer des ouvertures.\n" ..
                "3. Fais tes rotations horizontalement, pas verticalement.\n" ..
                "4. Recupere le buff reset CD des qu'il peut faire basculer un node.",
            planB =
                "Si vous perdez le tempo, arrete les traversees inutiles et stabilise d'abord ton triangle horizontal.",
            avoid = {
                "Mettre trop de joueurs au Market.",
                "Traverser verticalement pour rien.",
                "Ignorer le buff reset CD.",
            },
            roles = { "2 defense Market", "floater rapide", "ninja node", "joueur attentif au buff" },
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
            objective = "Joue le prochain node, pas le node impossible.",
            planA =
                "1. 6 joueurs mobiles suivent les apparitions.\n" ..
                "2. 2 harcelent les nodes ennemis pour casser leur tick.\n" ..
                "3. 2 defendent ceux deja tenus.\n" ..
                "4. Si un node est trop defencu, abandonne-le et va au suivant.",
            planB =
                "Si vous perdez le tempo, recentre les mobiles sur les prochains spawns au lieu d'insister sur un node deja perdu.",
            avoid = {
                "S'acharner sur un node verrouille.",
                "Jouer statique.",
                "Laisser un tick gratuit a l'ennemi.",
            },
            roles = { "mobiles", "harceleurs", "2 defenseurs", "shotcaller apparition" },
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
            objective = "Ne jamais perdre le fight central par surengage.",
            planA =
                "1. Applique match numbers partout : 1 ennemi dans un chariot = 1 reponse, pas 6.\n" ..
                "2. Le base sitter doit se repositionner avant le prochain spawn.\n" ..
                "3. Le milieu est la vraie win condition : ne l'affaiblis jamais pour un detail secondaire.",
            planB =
                "Si vous etes derriere, envoie des joueurs tanky dans leur chariot pour le casser vite, et joue l'orbe avec une compo qui spin. Si vous etes juste down d'un orbe, surcharge le milieu pour un wipe et un cap immediat.",
            avoid = {
                "Envoyer trop de monde dans un chariot.",
                "Reagir trop tard au respawn.",
                "Full wipe milieu.",
            },
            roles = { "base sitter intelligent", "anti-chariot", "core milieu", "clickeur orbe" },
        },
    },
}

-- ─── BGs EPIQUES (40v40) — FR + EN ───────────────────────────────────────────

MBGA_BGs[11] = {
    id      = "AV",
    nameKey = "BG_AV",
    isEpic  = true,
    format  = "Rush 40v40",
    strat = {
        fr = {
            objective = "C'est une course : prends les GY, brule les tours, tue le general avant l'ennemi.",
            planA =
                "1. Ne t'arrete jamais pour les fights du milieu.\n" ..
                "2. Brule les tours en parallele des captures de GY.\n" ..
                "3. Laisse Snowfall neutre cote Horde.\n" ..
                "4. Ne tape pas Drek/Vanndar trop tot : il faut assez de tours tombees avant.",
            planB =
                "Si le push se bloque, contourne le choke et prends le Relief Hut pour casser les respawns ennemis et acheter du temps a l'offense.",
            avoid = {
                "Turtle au choke.",
                "Caper Snowfall cote Horde.",
                "Oublier de laisser 2 joueurs sur chaque tour/bunker capture.",
            },
            roles = { "push massif", "cap tours", "mini defense tours", "classes rapides" },
        },
        en = {
            objective = "It's a race: grab GYs, burn towers, kill the general before the enemy.",
            planA =
                "1. Never stop for mid fights.\n" ..
                "2. Burn towers in parallel with GY captures.\n" ..
                "3. Leave Snowfall neutral on Horde side.\n" ..
                "4. Don't hit Drek/Vanndar too early: enough towers must fall first.",
            planB =
                "If the push stalls, ride around the choke and take the Relief Hut to break enemy respawns and buy time for offense.",
            avoid = {
                "Turtling at the choke.",
                "Capping Snowfall on Horde side.",
                "Forgetting to leave 2 players on each captured tower/bunker.",
            },
            roles = { "mass push", "tower cap", "tower mini-defense", "fast classes" },
        },
    },
}

MBGA_BGs[12] = {
    id      = "IOC",
    nameKey = "BG_IOC",
    isEpic  = true,
    format  = "Siege 40v40",
    strat = {
        fr = {
            objective = "Tu ne gagnes pas en tuant des joueurs. Tu gagnes en detruisant les portes avec le bon objectif cle.",
            planA =
                "1. Horde : Hangar + Workshop. Alliance : Docks + Glaives.\n" ..
                "2. Protege immediatement l'objectif asymetrique qui fait ta force.\n" ..
                "3. Backdoor : 3-5 joueurs se parachutent dans le fortin ennemi avec les Huge Seaforium Bombs.",
            planB =
                "Si ton objectif cle tombe, reprends-le tout de suite. Concentre le reste sur l'objectif secondaire utile, sans te disperser dans la rue.",
            avoid = {
                "Fight dans la rue.",
                "Laisser les Glaives ou l'airship sans protection.",
                "Jouer les vehicules en defense n'importe comment.",
            },
            roles = { "escorte vehicules", "reprise Hangar/Docks", "backdoor bombes", "defense point cle" },
        },
        en = {
            objective = "You don't win by killing players. You win by destroying the gates with the right key objective.",
            planA =
                "1. Horde: Hangar + Workshop. Alliance: Docks + Glaives.\n" ..
                "2. Immediately protect the asymmetric objective that gives your faction its edge.\n" ..
                "3. Backdoor: 3-5 players parachute into the enemy Keep with Huge Seaforium Bombs.",
            planB =
                "If your key objective falls, retake it immediately. Focus everything else on one useful secondary objective, don't spread out in the road.",
            avoid = {
                "Fighting in the road.",
                "Leaving Glaives or the airship undefended.",
                "Misusing vehicles on defense.",
            },
            roles = { "vehicle escort", "Hangar/Docks retake", "backdoor bombs", "key point defense" },
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
            objective = "Invoque l'Elemental avant l'ennemi, puis pousse la Route avec lui.",
            planA =
                "1. Split entre Route et events.\n" ..
                "2. Farm les fragments, turn-in vite, invoque Fangraal/Kronus.\n" ..
                "3. Avance groupe avec lui : il absorbe la majorite des degats.\n" ..
                "4. Protege tout joueur qui recupere l'Ancient Artifact.",
            planB =
                "Si tu perds le Ring of Conquest, ne retente pas en frontal direct : farm events en masse, invoque l'Elemental avant eux, puis reviens avec cet avantage.",
            avoid = {
                "Ignorer les events.",
                "Se suicider pour reprendre le Ring frontalement.",
                "Oublier les backdoors qui forcent les rotations ennemies.",
            },
            roles = { "farm fragments", "events", "push Route", "protect AA", "rogues backdoor" },
        },
        en = {
            objective = "Summon the Elemental before the enemy, then push the Road with it.",
            planA =
                "1. Split between Road and events.\n" ..
                "2. Farm fragments, turn in fast, summon Fangraal/Kronus.\n" ..
                "3. Push the road grouped with it: it absorbs most damage.\n" ..
                "4. Protect any player holding the Ancient Artifact.",
            planB =
                "If you lose the Ring of Conquest, don't retry frontally. Mass farm events, summon the Elemental first, then return with that advantage.",
            avoid = {
                "Ignoring events.",
                "Dying to retake the Ring frontally.",
                "Forgetting backdoors that force enemy rotations.",
            },
            roles = { "fragment farm", "events", "Road push", "protect AA", "stealth backdoor" },
        },
    },
}

MBGA_BGs[14] = {
    id      = "WG",
    nameKey = "BG_WG",
    isEpic  = true,
    format  = "Attaque/Defense 40v40",
    strat = {
        fr = {
            objective = "En attaque, perce un mur avec une masse de vehicules. En defense, tue les vehicules avant tout.",
            planA =
                "1. Attaque : attends 10-16 Siege Engines, pousse groupe sur un seul mur cote Ouest avec diversion ailleurs.\n" ..
                "2. Defense : joueurs aux canons, focus vehicules uniquement, puis repli dans la cour interieure si besoin.\n" ..
                "3. Une breche ouverte : continue dans LE MEME TROU. Ne change pas de mur.",
            planB =
                "Attaque : si Workshop conteste, overload un seul Workshop ou tente un ninja du second. Defense : si le mur interieur tombe, joue autour de la Relique et abuse des canons interieurs.",
            avoid = {
                "Pousser avec 2-3 vehicules isoles.",
                "Construire des catapultes de defense quand tu peux faire mieux.",
                "Changer de mur en pleine percee.",
            },
            roles = { "pilotes", "escorte vehicules", "diversion", "defense canons", "relique" },
        },
        en = {
            objective = "On attack, breach a wall with massed vehicles. On defense, kill vehicles above all else.",
            planA =
                "1. Attack: wait for 10-16 Siege Engines, push grouped on ONE wall (West side) with a diversion elsewhere.\n" ..
                "2. Defense: players on cannons, focus vehicles only, then fall back to inner courtyard if needed.\n" ..
                "3. Breach open: keep pushing THROUGH THE SAME HOLE. Don't switch walls.",
            planB =
                "Attack stuck: overload one Workshop or ninja the second. Defense breached: inner courtyard + players continuously interrupting the Relic.",
            avoid = {
                "Pushing with 2-3 isolated vehicles.",
                "Building defensive catapults when better options exist.",
                "Switching walls mid-breach.",
            },
            roles = { "pilots", "vehicle escort", "diversion", "cannon defense", "relic guard" },
        },
    },
}

MBGA_BGs[15] = {
    id      = "SR",
    nameKey = "BG_SR",
    isEpic  = true,
    format  = "3 phases 40v40 - Midnight",
    strat = {
        fr = {
            objective = "Progresse sans t'arreter pour kill, puis commit total sur le boss apres avoir desactive les Ethereal Defenses.",
            planA =
                "1. Push team sur Refinery puis Path of Predation puis Bastion.\n" ..
                "2. Une equipe laterale recrute les boss PNJ en parallele.\n" ..
                "3. Phase 3 : desactive les Ethereal Defenses, cap le Bastion, envoie une stall team sur le GY ennemi et commit fort sur Domanaar.",
            planB =
                "Si la Refinery tombe, tente la reprise sans stopper completement le push. Si Refinery + Path sont perdus, seul un gros retour en masse peut relancer la partie.",
            avoid = {
                "S'arreter pour farm les kills.",
                "Arriver degroupe au Path.",
                "Oublier les Ethereal Defenses.",
                "Tenter le boss sans stall team.",
            },
            roles = { "push team", "response team", "objectif lateral", "stall team", "CC de masse" },
        },
        en = {
            objective = "Progress without stopping to kill, then full commit on the boss after disabling the Ethereal Defenses.",
            planA =
                "1. Push team on Refinery, then Path of Predation, then Bastion.\n" ..
                "2. A side team recruits NPC bosses in parallel.\n" ..
                "3. Phase 3: disable Ethereal Defenses, cap Bastion, send a stall team to the enemy GY, full commit on Domanaar.",
            planB =
                "If the Refinery falls, attempt a retake without fully stopping the push. If both Refinery and Path are lost, only a full mass comeback can turn the game.",
            avoid = {
                "Stopping to farm kills.",
                "Arriving ungrouped at the Path.",
                "Forgetting the Ethereal Defenses.",
                "Attempting the boss without a stall team.",
            },
            roles = { "push team", "response team", "side objective", "stall team", "mass CC" },
        },
    },
}
"""

with open("d:/MBGA/Core/StrategyData.lua", "w", encoding="utf-8") as f:
    f.write(lua)

print("OK - StrategyData.lua written successfully")
print(f"Size: {len(lua)} chars")
