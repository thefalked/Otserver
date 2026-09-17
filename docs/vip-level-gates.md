# VIP level entry gates (Vip2-Vip9)

VIP status alone is not enough to enter Vip2-Vip8 areas. Each of those StepIn tiles also checks player level. Underleveled players are kicked to the temple at `{155, 52, 7}` with a cancel message.

Vip2-Vip6 still gate by level. They use lower thresholds so a ~3000 player can use mid VIP hunts. Vip7-Vip8 stay locked until higher levels. Vip9 has no level gate. It only checks VIP9 storage.

Paid VIP (`vipe.lua`, uniqueid `13700`) has **no** level gate. It only checks VIP days storage `13545`.

## Levels

| Tier | Min level | Scripts | `movements.xml` uniqueid |
| --- | ---: | --- | --- |
| Vip2 | 800 | `vip.lua`, `vip2.lua` | `13540`, `13539` |
| Vip3 (Master Vip) | 1200 | `vip3.lua` | `15967` |
| Vip4 (Baiakzik) | 1800 | `vip4.lua` | `5722` |
| Vip4 orphan | 1800 | `vip4b.lua` | `5721` |
| Vip5 (Super Vip) | 2500 | `vip5.lua` | `7520` |
| Vip6 (Mega Vip) | 3000 | `vip6.lua` | `7525` |
| Vip7 | 4000 | `vip7.lua` | `7526` |
| Vip8 | 5000 | `vip8.lua` | `7527` |
| Vip9 | *(none)* | `vip9.lua` | `13589` |

Scripts live under `server/data/movements/scripts/`. Wiring is in `server/data/movements/movements.xml`.

Map checks (live tiles): ActionID and UniqueID match for Vip3-Vip9 gates. The live Vip4 entry is `5722` (`vip4.lua`). Uniqueid `5721` (`vip4b.lua`) is kept as an orphan gate with no matching map tile found.

Matching quest reward chests live under `server/data/actions/scripts/` with the same VIP names (`vip3.lua`, `vip4.lua`, `vip5.lua`-`vip8.lua`). Those scripts grant VIP storage on use. The Vip4 chest (`uniqueid="7515"`) sets storage `5722`.

The Baiakzik set chest (`uniqueid="7514"`, `baiakzik_set.lua`) is separate. It grants set items and uses storage `7514`. It does not grant VIP entry status.

## Design notes

VIP quests are easy. A ~3000 player can finish through Vip8. Level gates stop a low-level character with VIP status from sitting in Vip2-Vip8 hunts, while keeping mid VIP usable around that pace. Vip9 only checks VIP status.

Check order on StepIn (Vip2-Vip8):

1. Level (`requiredLevel`)
2. VIP storage (existing quest / status check)

Vip9 skips the level check and only runs the VIP storage check.

## How to change

Edit `requiredLevel` in the matching movement script, then reload movements or restart the server.

Example from `vip.lua`:

```lua
local requiredLevel = 800
if getPlayerLevel(cid) < requiredLevel then
  doPlayerSendCancel(cid, "Somente level " .. requiredLevel .. " ou mais podem entrar nesta VIP.")
  doTeleportThing(cid, teleport1)
  return false
end
```
