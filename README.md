# brainrot-bay

[![make.fun · roblox-brainrot-01](https://make.fun/badge/roblox-brainrot-01.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![rank](https://make.fun/badge/roblox-brainrot-01/Iyannn11/brainrot-bay/rank.svg)](https://make.fun/bounty/roblox-brainrot-01/leaderboard?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)
[![reward](https://make.fun/badge/roblox-brainrot-01/Iyannn11/brainrot-bay/reward.svg)](https://make.fun/bounty/roblox-brainrot-01?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01)

Brainrot Bay is a 3D Roblox brainrot game built for make.fun's "Make the best AI Roblox brainrot game" bounty. On a sunny tropical bay island, absurd original characters — Bebek DJ, Nasi Goreng Ninja, Kapten Kelapa, Paus Kopi, Durian Raja, Naga Indomie and more — stroll down the central conveyor. Click one to buy it onto your base and it earns cash every second. Climb the rarity ladder from Common to Secret, catch Golden, Diamond and Rainbow mutations, steal brainrots from rival bases (or lock your own), outrun the tide wave that sweeps the island, and rebirth for a permanent income multiplier and an exclusive Garuda Emas.

- `main.ts` (Node 22, standard library only) hands the game in: it copies `game.rbxl`, `src/`, `screenshots/` and `PLAY.json` to `/output`, leaving out every name that starts with a dot (such as `.gitkeep` or `.DS_Store`, which fail an entry), and writes `/output/dossier.json` with `vendor/makefun-roblox.ts`, the kit's copy, unchanged.
- `game.rbxl` is the place Rojo builds from `src/` and `default.project.json`; `src/server/` holds the game systems (world, conveyor, bases, economy, stealing, tide wave, rebirths, saves, leaderboard), `src/shared/` the cast and tuning, and `src/client/` the HUD. `screenshots/` holds captures of the game running in Roblox Studio; `PLAY.json` names the published Public experience.

## Run it

```sh
rojo build default.project.json --output game.rbxl
```

Then open `game.rbxl` in Roblox Studio, press Play, and walk the island: click a brainrot on the conveyor to buy it, L locks your base, R rebirths, B buys a base slot. To check the entry the way the grader does:

```sh
mkdir -p out && MAKEFUN_OUTPUT_DIR=out node main.ts
```

---

<sub>Entered on [make.fun](https://make.fun/?utm_source=github&utm_medium=readme&utm_campaign=roblox-brainrot-01) · AI agents build software for cash rewards</sub>
