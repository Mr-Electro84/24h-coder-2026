import { readdirSync, readFileSync, statSync, existsSync } from "node:fs";
import { join, resolve } from "node:path";
import { validateGameMeta, type GameMeta } from "../src/types/game.js";

const EXCLUDED = new Set([
  "web",
  "node_modules",
  ".git",
  ".github",
  ".claude",
  ".planning",
  "dist",
]);

export type DiscoveredGame = {
  meta: GameMeta;
  metaPath: string;
  sourceAbs: string;
};

export type DiscoveryResult = {
  games: DiscoveredGame[];
  warnings: string[];
};

export function discoverGames(repoRoot: string): DiscoveryResult {
  const warnings: string[] = [];
  const games: DiscoveredGame[] = [];
  const seenIds = new Map<string, string>();

  const root = resolve(repoRoot);
  for (const entry of readdirSync(root)) {
    if (entry.startsWith(".")) continue;
    if (EXCLUDED.has(entry)) continue;
    const abs = join(root, entry);
    let st;
    try {
      st = statSync(abs);
    } catch {
      continue;
    }
    if (!st.isDirectory()) continue;

    const metaPath = join(abs, "game.json");
    if (!existsSync(metaPath)) continue;

    let raw: unknown;
    try {
      raw = JSON.parse(readFileSync(metaPath, "utf8"));
    } catch (e) {
      warnings.push(`[${entry}/game.json] JSON invalide: ${(e as Error).message}`);
      continue;
    }

    const result = validateGameMeta(raw, `${entry}/game.json`);
    if (result.ok === false) {
      warnings.push(...result.errors);
      continue;
    }
    const meta = result.meta;

    const sourceAbs = join(root, meta.sourceDir);
    if (!existsSync(sourceAbs) || !statSync(sourceAbs).isDirectory()) {
      warnings.push(`[${entry}/game.json] sourceDir "${meta.sourceDir}" introuvable`);
      continue;
    }

    const coverAbs = join(sourceAbs, meta.coverPath);
    if (!existsSync(coverAbs)) {
      warnings.push(`[${entry}/game.json] coverPath "${meta.coverPath}" introuvable`);
      continue;
    }

    const prev = seenIds.get(meta.id);
    if (prev) {
      warnings.push(`[${entry}/game.json] id "${meta.id}" déjà utilisé par ${prev}`);
      continue;
    }
    seenIds.set(meta.id, entry);

    games.push({ meta, metaPath, sourceAbs });
  }

  games.sort((a, b) => a.meta.title.localeCompare(b.meta.title, "fr"));
  return { games, warnings };
}
