# MBGA — Suivi du projet

> Dernière mise à jour : 25 mars 2026  
> À lire avec `Claude.md` pour reprendre le projet.

---

## État général

| Phase | Description                                   | Statut          |
| ----- | --------------------------------------------- | --------------- |
| 1     | Structure de l'addon, .toc, init              | ✅ Done         |
| 2     | Navigation complète grille → fiche → retour   | ✅ Done         |
| 3     | Switch FR / EN fonctionnel                    | ✅ Done         |
| 4     | Switch Horde / Alliance (couleurs UI)         | ✅ Done         |
| 2b    | Interface carte MDT-style (BGMapFrame)        | ✅ Done         |
| 2c    | Refonte BGMapFrame v2 (2 onglets STRAT/RÔLES) | ✅ Done         |
| 5     | Détection automatique du BG (API live)        | ❌ Non commencé |
| 6     | Scan de la composition du groupe              | ❌ Non commencé |
| 7     | Attribution des rôles                         | ❌ Non commencé |
| 8     | Envoi des 3 messages chat                     | ❌ Non commencé |

---

## Fichiers — état actuel

| Fichier                       | Statut     | Notes                                                |
| ----------------------------- | ---------- | ---------------------------------------------------- |
| `MBGA.toc`                    | ✅ Final   | Interface: 120000 (Midnight 12.0.0)                  |
| `MBGA.lua`                    | ✅ Final   | ADDON_LOADED vérifie `"MBGA"`, slash `/mbga`         |
| `Core/StrategyData.lua`       | ✅ Final   | 15 BGs complets, textes réécrits, sans → ni ×        |
| `UI/MainFrame.lua`            | ✅ Final   | Click BG → MBGA_OpenBGMapFrame() désormais           |
| `UI/StrategyFrame.lua`        | ✅ Archivé | Remplacé par BGMapFrame (accessible si besoin)       |
| `Core/BGMapData.lua`          | ✅ Final   | 15 BGs : nodes, spawns, 3 étapes chacun              |
| `UI/BGMapFrame.lua`           | ✅ Final   | **v2** — 2 onglets STRAT/RÔLES, header avec factions |
| `Locale/frFR.lua`             | ✅ Final   | Noms officiels FR (Wowhead) + corrections user       |
| `Locale/enUS.lua`             | ✅ Final   | Textes EN, pas d'emoji                               |
| `Core/BattlegroundDetect.lua` | ❌ À créer | Phase 5                                              |
| `Core/RoleAssigner.lua`       | ❌ À créer | Phase 7                                              |
| `Core/ChatMessenger.lua`      | ❌ À créer | Phase 8                                              |

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

## Derniers ajouts (BGMapFrame v2 — session 25 mars 2026)

### Refonte complète de `UI/BGMapFrame.lua`

Réécriture totale sur la base des maquettes Excalidraw partagées par le user.  
Taille : 1000×660. Nouveau layout :

- **Header** : `← Retour` | `Make BG's Great Again` (FRIZQT, centré) | `[Horde]` `[Alliance]` | `×`
- **Bandeau nom BG** : pleine largeur, 26px, nom du BG en doré centré
- **Zone carte** (gauche, 760px) : tiles 4×3, zoom molette, pan clic-glisser — identique à la v1
- **Panneau droit** (~212px) avec **2 onglets** :

  **Onglet STRAT** (par défaut) :
  - Carte `OBJECTIF PRINCIPAL` (52px, texte depuis `strat.fr.objective`)
  - Étapes numérotées dynamiques (depuis `BGMapData[i].steps_fr`) — boutons cliquables, highlight nodes + flèches
  - Bouton `PLAN B` (orange fonçé) — affiche `strat.fr.planB` dans la descBox
  - Bouton `ERREUR À NE PAS FAIRE` (rouge foncé) — affiche `strat.fr.avoid[]` dans la descBox
  - Zone description (82px, bas) — contenu de l'élément actif

  **Onglet RÔLES** :
  - Carte "ROLES ET CLASSES RECOMMANDÉS" — liste depuis `strat.fr.roles[]`
  - Carte "MEILLEURE COMP (PHASE 2)" — placeholder grisé, texte explicatif

- Boutons Horde/Alliance dans le header de BGMapFrame (`MBGA_Map_HordeBtn` / `MBGA_Map_AlliBtn`)
- Fonction `MBGA_UpdateMapFactionUI()` — mise à jour des couleurs faction dans la map frame
- `MBGA_UpdateFactionUI()` dans `MainFrame.lua` appelle désormais `MBGA_UpdateMapFactionUI()` si disponible

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

---

## Bugs connus — à corriger en priorité

### BUG 1 — La croix (×) ne ferme plus l'addon

Depuis la refonte BGMapFrame v2, le bouton `×` (`UIPanelCloseButton`) du header de la map frame
ne ferme plus l'interface correctement.

- **Symptôme** : clic sur `×` dans le header de BGMapFrame ne ferme pas la fenêtre.
- **À investiguer** : `UIPanelCloseButton` cache son parent frame par défaut — vérifier que
  `MBGA_BGMapFrame` est bien le parent direct du `closeBtn` et qu'aucun autre frame n'intercepte.
- **Fix attendu** : `×` cache `MBGA_BGMapFrame` uniquement (sans rouvrir la grille,
  contrairement à `← Retour`).

---

## Prochaine session — par où commencer

### Priorité 1 — Corriger BUG 1 (fermeture par ×)

Voir section "Bugs connus" ci-dessus.

### Priorité 2 — Calibration BG par BG (captures d'écran)

Ouvrir chaque BG dans l'addon, le user envoie une capture d'écran,
on compare les positions des nodes et on ajuste `Core/BGMapData.lua` ensemble, BG par BG.

Ordre suggéré (simple → complexe) :

1. Warsong Gulch → 2. Twin Peaks → 3. Arathi Basin → 4. Eye of the Storm
2. Battle for Gilneas → 6. Silvershard Mines → 7. Temple of Kotmogu
3. Deepwind Gorge → 9. Seething Shore → 10. Deephaul Ravine
4. Alterac Valley → 12. Isle of Conquest → 13. Ashran
5. Wintergrasp → 15. Slayer's Rise (tiles custom à créer)

### Priorité 3 — Enrichir l'onglet RÔLES avec exemples de classes

Actuellement l'onglet RÔLES affiche une liste de rôles textuels bruts (`strat.fr.roles[]`).

À faire : pour chaque rôle listé, afficher les **meilleures classes/specs** qui remplissent
ce rôle dans ce BG spécifique. Exemple pour Arathi Basin :

- `FC : Evoker Preservation, Druide Resto, Moine MW`
- `Défense node : Blood DK, Prot War, Prot Pala`
- `Ninja : Rogue (toutes specs), Druide Féral, DH Havoc`

Chaque entrée de `roles[]` dans `StrategyData.lua` deviendra une table
`{ role = "...", classes = { "...", "..." } }` — structure à définir ensemble.

### Option A — Calibration des tiles et des nodes (voir Priorité 2 ci-dessus)

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
