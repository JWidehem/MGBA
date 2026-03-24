# Make BG's Great Again (MBGA) — Guide Agent Complet

---

## 1. CONTEXTE DU PROJET

Addon WoW PvP pour **World of Warcraft : Midnight (Patch 12.0)**.  
Objectif : aider les joueurs PUG à gagner leurs battlegrounds en affichant les meilleures stratégies pour chaque map, et en automatisant les assignations de rôles à l'entrée d'un BG.

### Deux phases distinctes

**Phase 1 — Guide stratégique (UI pure, pas d'API live)**

- Fenêtre ouverte manuellement par le joueur
- Grille de 15 BGs (10 normaux + 5 épiques) avec icônes
- Clic sur un BG → fiche stratégie : win condition, règle critique, rôles, Plan A, Plan B
- Switch Horde / Alliance (change certains textes de strat)
- Switch FR / EN (BGs normaux = FR uniquement ; BGs épiques = FR + EN)

**Phase 2 — Auto-lead (logique + API WoW live)**

- Détection automatique du BG à l'entrée
- Scan composition du groupe (classe, spec, ilvl)
- Attribution des rôles selon les hiérarchies définies
- Envoi de 3 messages chat Raid espacés d'1 seconde

### Fichiers de référence du projet

- `Claude.md` — ce fichier, guidelines de l'agent
- `MBGA-Strat.md` — **source de vérité absolue** pour tout le contenu stratégique (15 BGs)
- `assets/Mrrglgamesh_icon.png` — icône de l'addon (utilisée dans le .toc)
- `assets/Mrrglgamesh_logo.png` — logo affiché dans la fenêtre principale

---

## 2. RÈGLE ABSOLUE AVANT DE CODER

**Avant d'écrire la moindre ligne de code, vérifier la documentation officielle de l'API WoW.**

- Documentation principale : https://warcraft.wiki.gg/wiki/World_of_Warcraft_API
- Référence FrameXML : https://github.com/Ketho/BlizzardInterfaceResources
- API battlegrounds : https://warcraft.wiki.gg/wiki/Category:API_Battleground_functions

**Checklist de validation pour toute fonction utilisée :**

- Existe-t-elle dans le patch 12.0 (Midnight) ?
- Est-elle dépréciée ou renommée depuis une version précédente ?
- Respecte-t-elle les restrictions de sécurité Blizzard (fonctions protégées) ?
- En cas de doute → chercher avant d'implémenter. Ne jamais supposer.

---

## 3. APIs WoW CRITIQUES — RÉFÉRENCE

### Détection du battleground

```lua
C_PvP.GetActiveMatchBracket()   -- bracket PvP actif (Midnight)
C_Map.GetBestMapForUnit("player") -- zone actuelle
GetBattlefieldInfo()            -- infos sur le BG actuel
```

### Scan de la composition

```lua
GetNumGroupMembers()                    -- nombre de membres du groupe
UnitClass("unitToken")                  -- classe du joueur ("WARRIOR", "PALADIN"...)
GetSpecializationInfo(specIndex)        -- spec active du joueur local
GetInspectSpecialization("unit")        -- spec d'un autre joueur (nécessite inspection)
NotifyInspect("unit")                   -- déclencher l'inspection d'un joueur
UnitFactionGroup("player")              -- "Horde" ou "Alliance"
GetAverageItemLevel()                   -- ilvl moyen du joueur connecté uniquement
-- ⚠️ L'ilvl des autres joueurs nécessite NotifyInspect + INSPECT_READY event
-- ⚠️ Vérifier si C_Inspect est disponible en Midnight
```

### Chat

```lua
SendChatMessage(msg, "RAID")
-- ⚠️ PROTÉGÉE — ne peut être appelée QUE depuis un événement hardware (clic bouton)
-- Ne JAMAIS appeler depuis un event automatique ou OnUpdate
-- Pour les 3 messages espacés : utiliser C_Timer.After(délai, callback)
```

### Timer

```lua
C_Timer.After(1, function() -- callback end)   -- délai 1 seconde entre messages
C_Timer.NewTicker(intervalle, callback, count) -- ticker optionnel
```

### Événements clés

```lua
PLAYER_ENTERING_WORLD       -- joueur entre dans une zone
UPDATE_BATTLEFIELD_STATUS   -- statut BG change
ZONE_CHANGED_NEW_AREA       -- changement de zone
GROUP_ROSTER_UPDATE         -- composition du groupe mise à jour
INSPECT_READY               -- inspection d'un joueur terminée
```

---

## 4. STRUCTURE DE FICHIERS

```
MakeBGsGreatAgain/
├── MakeBGsGreatAgain.toc       -- manifest addon (Interface: 120000 — Midnight 12.0.0)
├── MakeBGsGreatAgain.lua       -- point d'entrée, init, event routing
├── Core/
│   ├── BattlegroundDetect.lua  -- détection du BG actuel via API
│   ├── RoleAssigner.lua        -- attribution des rôles selon classe/spec/ilvl
│   ├── ChatMessenger.lua       -- envoi des 3 messages chat (C_Timer.After)
│   └── StrategyData.lua        -- toutes les données de stratégie (tables Lua)
├── UI/
│   ├── MainFrame.lua           -- fenêtre principale (grille des BGs)
│   ├── StrategyFrame.lua       -- fiche stratégie d'un BG
│   └── Textures/               -- textures UI spécifiques si nécessaire
└── Locale/
    ├── frFR.lua                -- textes français
    └── enUS.lua                -- textes anglais
```

---

## 5. LISTE DES 15 BGs

### Normaux (10) — Messages FR uniquement

| #   | Nom                | Format                 | Map                                  |
| --- | ------------------ | ---------------------- | ------------------------------------ |
| 1   | Warsong Gulch      | CTF 10v10              | Labyrinthe, rampes, tunnels          |
| 2   | Twin Peaks         | CTF 10v10              | Carte ouverte, falaise extérieure    |
| 3   | Arathi Basin       | Domination 15v15       | 5 nodes triangulaires, BS central    |
| 4   | Eye of the Storm   | Dom+CTF 15v15          | 4 tours + drapeau central            |
| 5   | Battle for Gilneas | Domination 15v15       | 3 nodes, Waterworks central          |
| 6   | Silvershard Mines  | Payload 10v10          | 3 chariots (Lava, Middle, Top)       |
| 7   | Temple of Kotmogu  | Orbes 10v10            | 4 orbes, temple avec piliers         |
| 8   | Deepwind Gorge     | Domination 15v15       | Market central, CD Reset Buff        |
| 9   | Seething Shore     | Nodes dynamiques 10v10 | Nodes qui apparaissent/disparaissent |
| 10  | Deephaul Ravine    | Payload+Cristal 10v10  | Chariots + orbe du milieu            |

### Épiques (5) — Messages FR + EN

| #   | Nom              | Format                    |
| --- | ---------------- | ------------------------- |
| 1   | Alterac Valley   | Rush général 40v40        |
| 2   | Isle of Conquest | Siège 40v40               |
| 3   | Ashran           | Route de la Gloire 40v40  |
| 4   | Wintergrasp      | Attaque/Défense 40v40     |
| 5   | Slayer's Rise    | 3 phases 40v40 (Midnight) |

---

## 6. LOGIQUE DE RÔLES — PHASE 2

### Priorité Flag Carrier (CTF — WSG, Twin Peaks)

```
1. Preservation Evoker
2. Resto Druid
3. Resto Shaman
4. Mistweaver Monk
5. Shadow Priest / Outlaw Rogue
6. Autres mobiles avec self-heal

JAMAIS FC : Holy Paladin (CDs désactivés avec le flag)
JAMAIS FC : MM Hunter
```

### Priorité Escort/Peeler défensif

```
1. Blood DK (Grip, chain, stun)
2. Frost Mage (Blizzard, Poly, Ice Wall)
3. Warrior (Shockwave, Fear, Storm Bolt, Intervene)
4. Ret Paladin (Freedom, BoP, LoH)
```

### Priorité Furtif/Ninja

```
1. Rogue (toute spec)
2. Druide Féral
3. DH Havoc
```

### Priorité Tank/Stall (nœuds, BS, Market)

```
1. Blood DK
2. Prot Warrior = Prot Paladin
3. Guardian Druid = Brewmaster = Vengeance DH
```

### Priorité Offense burst

```
1. MM Hunter (depuis camouflage)
2. Ret Paladin (Bubble + BoP + LoH aux Mines)
3. Sub Rogue (burst depuis stealth)
4. Boomkin (Incarnation)
5. Fire / Arcane Mage
```

### Tie-break entre joueurs éligibles pour un rôle

```
→ Meilleur item level (GetAverageItemLevel() pour soi, GetInspectSpecialization pour les autres)
```

---

## 7. STRUCTURE DES 3 MESSAGES CHAT

```
MSG 1 — Strat générale + win condition du BG
MSG 2 — Assignations nominatives avec variables dynamiques
MSG 3 — Plan B (instruction courte si ça part mal)
```

**Délai entre chaque message : 1 seconde** via `C_Timer.After`

### Variables dynamiques

`{FC1}`, `{FC2}`, `{ESCORT1}`, `{ESCORT2}`, `{TANK1}`, `{TANK2}`,  
`{HEAL1}`, `{HEAL2}`, `{FURTIF1}`, `{FURTIF2}`, `{DPS1}`…`{DPS8}`

### Langue

- BGs normaux : FR uniquement
- BGs épiques : FR + EN (les 2 messages dans les deux langues)

---

## 8. DESIGN UI — PRINCIPES ADAPTÉS WoW

### Contexte d'utilisation

L'addon est utilisé **en jeu, sous pression**, souvent dans les 20 secondes précédant le début d'un BG.  
Règle absolue : **ultra direct, feedback immédiat, lisibilité maximale**.  
Chaque écran doit permettre une décision en moins de 5 secondes.  
Tester mentalement : "un joueur qui utilise ça 100 fois sera-t-il encore à l'aise ?" — si non, simplifier.

### Hiérarchie visuelle — ordre impératif

Le flux visuel de la fiche stratégie doit correspondre au flux de décision du joueur :

1. **Win condition** (le plus grand, le plus visible)
2. **Règle critique** (⚠️ — avertissement ambre/jaune)
3. **Rôles** (assignations compactes)
4. **Plan A** (contenu principal)
5. **Plan B** (secondaire, moins visible)

Créer la hiérarchie par : **taille → graisse → contraste → position → couleur**  
Les métadonnées (sources, notes) ne doivent jamais concurrencer le contenu principal.

### Couleurs sémantiques — non négociables

| Couleur                 | Usage dans MBGA                     |
| ----------------------- | ----------------------------------- |
| Rouge Horde `#8B0000`   | Faction Horde, éléments Horde       |
| Bleu Alliance `#0070DD` | Faction Alliance, éléments Alliance |
| Ambre `#FFA500`         | ⚠️ Règles critiques, avertissements |
| Vert `#00CC44`          | Succès, confirmation                |
| Gris clair `#C0C0C0`    | Texte secondaire, métadonnées       |
| Blanc `#FFFFFF`         | Texte principal                     |

WoW est toujours en **dark mode** — la profondeur vient des différences de luminance entre surfaces,  
pas des ombres. Les frames imbriquées doivent être légèrement plus claires que le fond.

### États des boutons BG (grille principale)

- **Normal** : icône + nom du BG, fond neutre semi-transparent
- **Hover** : surbrillance légère (highlight Blizzard standard), curseur change
- **Actif/Sélectionné** : bordure colorée (rouge Horde ou bleu Alliance selon faction)
- **BG actuel détecté** : badge ou couleur distincte pour indiquer "vous êtes dans ce BG"

### Signifiants

- Tout élément cliquable doit visuellement sembler cliquable
- L'action principale (clic sur un BG) doit être évidente au premier regard
- Le bouton "← Retour" doit toujours être visible sur la fiche stratégie
- Le switch Horde/Alliance et FR/EN doivent indiquer clairement l'état actif

### Spacing — système 4 points (en pixels WoW)

- Padding interne des frames : multiples de 4 (8, 12, 16, 24, 32)
- Espace entre les sections de la fiche stratégie : 16px minimum
- Espace entre les icônes de BG dans la grille : 8px
- Plus d'espace entre les groupes qu'à l'intérieur des groupes

### Typographie WoW (fontes natives Blizzard)

- Titres de section : `Fonts\FRIZQT__.TTF` (Friz Quadrata — fonte WoW emblématique)
- Corps de texte : `Fonts\ARIALN.TTF` (Arial Narrow — lisibilité maximale)
- Hiérarchie : taille et graisse avant couleur
- Jamais plus de 3 tailles de texte sur un même écran

### Anti-patterns à éviter

- Surcharger la fiche stratégie — si un joueur met plus de 10 secondes à trouver le Plan A, c'est trop dense
- Animations décoratives — WoW addon doit être instantané, zéro friction
- Textes trop longs sur une seule ligne — utiliser des listes courtes
- Toutes les sections avec le même poids visuel — la win condition doit dominer
- Effets visuels qui ralentissent l'ouverture de la fenêtre

---

## 9. WIREFRAMES DE RÉFÉRENCE

### Fenêtre principale

```
┌─────────────────────────────────────────────────────┐
│  [🔴 Horde]    Make BG's Great Again    [🔵 Alliance] │
│                    [FR] / [EN]                       │
├─────────────────────────────────────────────────────┤
│  BATTLEGROUNDS (10v10 / 15v15)                       │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                 │
│  │ BG │ │ BG │ │ BG │ │ BG │ │ BG │                 │
│  └────┘ └────┘ └────┘ └────┘ └────┘                 │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                 │
│  │ BG │ │ BG │ │ BG │ │ BG │ │ BG │                 │
│  └────┘ └────┘ └────┘ └────┘ └────┘                 │
├─────────────────────────────────────────────────────┤
│  EPIC BATTLEGROUNDS (40v40)                          │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐                 │
│  │ BG │ │ BG │ │ BG │ │ BG │ │ BG │                 │
│  └────┘ └────┘ └────┘ └────┘ └────┘                 │
└─────────────────────────────────────────────────────┘
```

### Fiche stratégie

```
┌─────────────────────────────────────────────────────┐
│  ← Retour           ARATHI BASIN          [H] / [A] │
├─────────────────────────────────────────────────────┤
│  🎯 WIN CONDITION                                    │
│  Première équipe à 1600 ressources gagne.            │
├─────────────────────────────────────────────────────┤
│  ⚠️ RÈGLE CRITIQUE                                  │
│  Maximum 2 joueurs au Blacksmith.                    │
│  Un 3v2 avec healer = éternité → vous perdez tout   │
│  le reste de la map.                                 │
├─────────────────────────────────────────────────────┤
│  RÔLES                                               │
│  [BS : 1 heal tanky + 1 DPS disruptif]              │
│  [LM : 1 heal mobile + knockback]                   │
│  [Mines : Ret Pala + burst depuis stealth]          │
├─────────────────────────────────────────────────────┤
│  📋 PLAN A                                           │
│  1. 3 groupes capent leur triangle simultanément    │
│  2. Mines : Ret Pala pop TOUS ses CDs d'entrée      │
│  3. Contestez leurs nodes — ne jouez pas que le     │
│     vôtre                                           │
├─────────────────────────────────────────────────────┤
│  🔄 PLAN B (si ça part mal)                         │
│  0-1 node : tout le monde au BS, extension ensuite  │
└─────────────────────────────────────────────────────┘
```

---

## 10. RÈGLES DE DÉVELOPPEMENT

### Lua & WoW

- **Lua natif WoW uniquement** — zéro librairie externe, zéro dépendance
- Ne jamais appeler une fonction protégée hors d'un événement hardware (clic bouton)
- `SendChatMessage` → uniquement via callback déclenché par un bouton
- Tester chaque module indépendamment avant intégration
- Utiliser `C_Timer.After` pour les délais, jamais de boucle bloquante
- Commenter le code en français
- PascalCase pour les noms de frames (`MBGA_MainFrame`, `MBGA_StratFrame`)
- camelCase pour les variables locales (`currentBG`, `playerFaction`)
- Préfixer toutes les variables globales de `MBGA_` pour éviter les conflits

### Données stratégiques

- Toutes les strats viennent de `MBGA-Strat.md` — ne jamais inventer de contenu
- Les données sont stockées en tables Lua dans `Core/StrategyData.lua`
- Structure par BG : `{ id, name, type, winCondition, criticalRule, roles, planA, planB }`
- Les textes bilingues sont des sous-tables `{ fr = "...", en = "..." }`

### Sécurité

- Ne jamais stocker de données personnelles des joueurs
- Ne jamais envoyer de requêtes réseau externes
- Ne jamais modifier le comportement du jeu au-delà de l'affichage UI et du chat

---

## 11. ORDRE DE DÉVELOPPEMENT

### Étape 1 — Fiche stratégie statique

Afficher le contenu d'un BG hardcodé sans aucune logique live.  
Valider : lisibilité, hiérarchie visuelle, navigation.

### Étape 2 — Navigation complète

Grille principale fonctionnelle + clic vers la fiche + bouton Retour.  
Toutes les 15 fiches accessibles avec leur contenu.

### Étape 3 — Switch FR / EN

Toutes les chaînes de texte passent par `Locale/frFR.lua` et `Locale/enUS.lua`.

### Étape 4 — Switch Horde / Alliance

Textes faction-spécifiques dans les strats épiques + couleurs UI adaptées.

### Étape 5 — Détection automatique du BG

Utiliser les événements WoW pour détecter le BG actuel et l'afficher en surbrillance dans la grille.

### Étape 6 — Scan de la composition

Lire classe + spec + ilvl de chacun membres du groupe.

### Étape 7 — Attribution des rôles

Algorithme d'attribution selon les priorités définies en section 6.

### Étape 8 — Envoi des messages chat

Les 3 messages avec variables dynamiques remplacées, espacés d'1 seconde.
