# MBGA — Suivi du projet

> Dernière mise à jour : 24 mars 2026  
> À lire avec `Claude.md` pour reprendre le projet.

---

## État général

| Phase | Description                                 | Statut          |
| ----- | ------------------------------------------- | --------------- |
| 1     | Structure de l'addon, .toc, init            | ✅ Done         |
| 2     | Navigation complète grille → fiche → retour | ✅ Done         |
| 3     | Switch FR / EN fonctionnel                  | ✅ Done         |
| 4     | Switch Horde / Alliance (couleurs UI)       | ✅ Done         |
| 2b    | Interface carte MDT-style (BGMapFrame)      | ✅ Done         |
| 5     | Détection automatique du BG (API live)      | ❌ Non commencé |
| 6     | Scan de la composition du groupe            | ❌ Non commencé |
| 7     | Attribution des rôles                       | ❌ Non commencé |
| 8     | Envoi des 3 messages chat                   | ❌ Non commencé |

---

## Fichiers — état actuel

| Fichier                       | Statut     | Notes                                          |
| ----------------------------- | ---------- | ---------------------------------------------- |
| `MBGA.toc`                    | ✅ Final   | Interface: 120000 (Midnight 12.0.0)            |
| `MBGA.lua`                    | ✅ Final   | ADDON_LOADED vérifie `"MBGA"`, slash `/mbga`   |
| `Core/StrategyData.lua`       | ✅ Final   | 15 BGs complets, textes réécrits, sans → ni ×  |
| `UI/MainFrame.lua`            | ✅ Final   | Click BG → MBGA_OpenBGMapFrame() désormais     |
| `UI/StrategyFrame.lua`        | ✅ Archivé | Remplacé par BGMapFrame (accessible si besoin) |
| `Core/BGMapData.lua`          | ✅ Final   | 15 BGs : nodes, spawns, 3 étapes chacun        |
| `UI/BGMapFrame.lua`           | ✅ Final   | Carte MDT-style : tiles, nodes, flèches, steps |
| `Locale/frFR.lua`             | ✅ Final   | Noms officiels FR (Wowhead) + corrections user |
| `Locale/enUS.lua`             | ✅ Final   | Textes EN, pas d'emoji                         |
| `Core/BattlegroundDetect.lua` | ❌ À créer | Phase 5                                        |
| `Core/RoleAssigner.lua`       | ❌ À créer | Phase 7                                        |
| `Core/ChatMessenger.lua`      | ❌ À créer | Phase 8                                        |

---

## Ce qui fonctionne aujourd'hui

- `/mbga` ouvre la fenêtre principale (cachée au login)
- Grille de 15 BGs avec leurs noms dans la langue active
- Clic sur un BG → **carte interactive MDT-style** (`BGMapFrame`) :
  - Canvas 760×540 visible (tiles Blizzard WorldMap 4×3, chacune 190×190)
  - **Nodes** positionnés sur la carte avec abréviation + label + tooltip
  - **Panneau droit** : liste d'étapes cliquables (1, 2, 3…)
  - Clic sur une étape → **highlights** (anneau doré sur les nodes ciblés) + **flèches** (CreateLine)
  - **Zoom** via molette (×0.6 à ×3.0), pan via clic-glisser
  - Bouton `← Retour` → retour à la grille principale
  - Description de l'étape active dans la boîte en bas du panneau
  - Fallback fond uni si les tiles Blizzard ne chargent pas (BGs nouveaux ou paths à calibrer)
- Boutons Horde (rouge) / Alliance (bleu) dans le header de la grille
- Boutons FR / EN dans la grille (BGs épiques affichent steps_en si disponibles)

---

## Derniers ajouts (BGMapFrame — session MDT-style)

### Nouveaux fichiers

- `Core/BGMapData.lua` — données cartographiques des 15 BGs :
  - Positions (x, y) approximatives des nodes (à calibrer in-game)
  - Spawns Horde/Alliance
  - 3 étapes par BG (steps_fr + steps_en pour les épiques)
  - Flèches directionnelles (from/to par nodeId ou spawn)

- `UI/BGMapFrame.lua` — interface MDT-like complète :
  - Frame 990×620, header 44px, canvas 760×540, panneau droit 200px
  - 12 tiles Blizzard WorldMap (4×3 grille de 190×190 à scale=1)
  - Blips de nodes : fond coloré + abréviation + anneau MiniMap-TrackingBorder
  - Zoom molette (SCALE_MIN=0.6, SCALE_MAX=3.0) → retile + reposition nodes
  - Pan clic-glisser → contenu clipé par un clipFrame
  - Étapes cliquables → highlights sur nodes + redraw flèches (CreateLine)
  - Bouton ← Retour → retour à MBGA_MainFrame

### Modifications

- `MBGA.toc` : `Core\BGMapData.lua` + `UI\BGMapFrame.lua` ajoutés
- `UI/MainFrame.lua` : click sur BG → `MBGA_OpenBGMapFrame()` au lieu de `MBGA_OpenStrategyFrame()`

### Calibration in-game requise

- Vérifier que les tiles Blizzard WorldMap chargent pour chaque BG
- Ajuster les positions (x, y) des nodes dans BGMapData.lua pour correspondre à la vraie carte
- Slayer's Rise (BG 15) : tiles custom à créer (mapFolder = "" → fond uni pour l'instant)

---

## Prochaine session — par où commencer

### Option A — Calibration des tiles et des nodes

Charger l'addon en jeu, ouvrir chaque BG, vérifier les tiles et ajuster
les positions des nodes dans `Core/BGMapData.lua`.

### Option B — Phase 5 : Détection automatique du BG

Créer `Core/BattlegroundDetect.lua`.
Écouter `PLAYER_ENTERING_WORLD` + `UPDATE_BATTLEFIELD_STATUS`.
Appeler `C_PvP.GetActiveMatchBracket()` et `C_Map.GetBestMapForUnit("player")`.
Résultat : le BG actuel est mis en surbrillance dans la grille ET la carte s'ouvre automatiquement.

### Option C — Améliorer les étapes de la carte

Affiner les descriptions d'étapes dans `BGMapData.lua` en se basant sur `MBGA-Strat.md`.
Ajouter des étapes supplémentaires pour les BGs complexes (AV, IoC).

---

## Points techniques à ne pas oublier

- **Polices WoW** : ARIALN.TTF et FRIZQT\_\_.TTF ne supportent pas `→ × ⚠️ 🎯` → toujours utiliser `->`, `x`, texte brut
- **SendChatMessage** : protégée — uniquement depuis un clic bouton, jamais depuis un event automatique
- **C_Timer.After** pour les délais entre messages (pas de boucle bloquante)
- **NotifyInspect** nécessaire pour lire le spec/ilvl des autres joueurs (event `INSPECT_READY`)
- **Prefixe global** : toutes les variables globales préfixées `MBGA_`

---

## Repo Git

- URL : https://github.com/JWidehem/MGBA.git
- Branche : `main`
- Dernier commit : `5f73764` — réécriture strats
