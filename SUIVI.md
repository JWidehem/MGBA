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
| 5     | Détection automatique du BG (API live)      | ❌ Non commencé |
| 6     | Scan de la composition du groupe            | ❌ Non commencé |
| 7     | Attribution des rôles                       | ❌ Non commencé |
| 8     | Envoi des 3 messages chat                   | ❌ Non commencé |

---

## Fichiers — état actuel

| Fichier                       | Statut     | Notes                                             |
| ----------------------------- | ---------- | ------------------------------------------------- |
| `MBGA.toc`                    | ✅ Final   | Interface: 120000 (Midnight 12.0.0)               |
| `MBGA.lua`                    | ✅ Final   | ADDON_LOADED vérifie `"MBGA"`, slash `/mbga`      |
| `Core/StrategyData.lua`       | ✅ Final   | 15 BGs complets, textes réécrits, sans → ni ×     |
| `UI/MainFrame.lua`            | ✅ Final   | Grille 5×3 centrée, PADDING=29, f:Hide() au login |
| `UI/StrategyFrame.lua`        | ✅ Final   | 5 boîtes colorées, layout dynamique               |
| `Locale/frFR.lua`             | ✅ Final   | Noms officiels FR (Wowhead) + corrections user    |
| `Locale/enUS.lua`             | ✅ Final   | Textes EN, pas d'emoji                            |
| `Core/BattlegroundDetect.lua` | ❌ À créer | Phase 5                                           |
| `Core/RoleAssigner.lua`       | ❌ À créer | Phase 7                                           |
| `Core/ChatMessenger.lua`      | ❌ À créer | Phase 8                                           |

---

## Ce qui fonctionne aujourd'hui

- `/mbga` ouvre la fenêtre principale (cachée au login)
- Grille de 15 BGs avec leurs noms dans la langue active
- Clic sur un BG → fiche stratégie avec 5 sections colorées :
  - **OBJECTIF DE VICTOIRE** (doré)
  - **REGLE CRITIQUE** (ambre)
  - **COMPOSITION** (gris)
  - **PLAN A** (bleu)
  - **PLAN B** (gris foncé)
- Boutons Horde (rouge) / Alliance (bleu) dans le header
- Boutons FR / EN dans la fiche (BGs épiques uniquement)
- Bouton `< Retour` / `< Back` adapté à la langue
- Layout dynamique : les boîtes se redimensionnent selon le texte

---

## Derniers correctifs réalisés (session du 24 mars 2026)

- Réécriture complète des 15 BGs dans `StrategyData.lua`
  - Texte accessible aux débutants (jargon expliqué, lieux décrits)
  - `→` remplacé par `->` partout (non supporté par ARIALN.TTF)
  - `×` remplacé par `x` partout
  - `—` et `−` supprimés des chaînes de jeu
  - "Snowfall GY", "IBGY", "Balinda", etc. → expliqués en clair
- Commit pushé : `5f73764` sur `main`

---

## Prochaine session — par où commencer

### Option A — Phase 5 : Détection automatique du BG

Créer `Core/BattlegroundDetect.lua`.  
Écouter `PLAYER_ENTERING_WORLD` + `UPDATE_BATTLEFIELD_STATUS`.  
Appeler `C_PvP.GetActiveMatchBracket()` et `C_Map.GetBestMapForUnit("player")`.  
Résultat : le BG actuel est mis en surbrillance dans la grille.

### Option B — Tests visuels en jeu

Charger l'addon en jeu (dossier `Interface/AddOns/MBGA`), tester les 15 fiches, vérifier le rendu des 5 boîtes, corriger si nécessaire.

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
