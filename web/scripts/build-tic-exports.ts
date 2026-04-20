import { execFileSync, spawnSync } from "node:child_process";
import { cpSync, existsSync, mkdirSync, readFileSync, renameSync, rmSync, writeFileSync } from "node:fs";
import { dirname, join, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { discoverGames, type DiscoveredGame } from "./discover-games.js";

const __dirname = dirname(fileURLToPath(import.meta.url));
const WEB_DIR = resolve(__dirname, "..");
const REPO_ROOT = resolve(WEB_DIR, "..");
const TMP_DIR = join(WEB_DIR, ".tmp");
const GAMES_OUT = join(WEB_DIR, "public", "games");
const SHARED_OUT = join(GAMES_OUT, "_shared");
const COVERS_OUT = join(WEB_DIR, "public", "covers");
const GENERATED = join(WEB_DIR, "src", "data", "games.generated.ts");

function findTic80(): string {
  const env = process.env.TIC80_BIN;
  if (env && existsSync(env)) return env;
  const macApp = "/Applications/tic80.app/Contents/MacOS/tic80";
  if (existsSync(macApp)) return macApp;
  const which = spawnSync("which", ["tic80"], { encoding: "utf8" });
  if (which.status === 0 && which.stdout.trim()) return which.stdout.trim();
  console.error(
    "TIC-80 introuvable. Installe-le (https://tic80.com/) ou définis TIC80_BIN=/chemin/vers/tic80."
  );
  process.exit(1);
  throw new Error("unreachable");
}

function runTic80(bin: string, fsDir: string, cmd: string): { ok: boolean; output: string } {
  const useXvfb = process.platform === "linux" && !process.env.SKIP_XVFB;
  const exe = useXvfb ? "xvfb-run" : bin;
  const args = useXvfb ? ["-a", bin, "--cli", "--fs", fsDir, "--cmd", cmd] : ["--cli", "--fs", fsDir, "--cmd", cmd];
  const r = spawnSync(exe, args, { encoding: "utf8", timeout: 60_000 });
  return {
    ok: r.status === 0,
    output: `${r.stdout ?? ""}\n${r.stderr ?? ""}`.trim(),
  };
}

function unzip(zipPath: string, destDir: string) {
  mkdirSync(destDir, { recursive: true });
  execFileSync("unzip", ["-o", "-q", zipPath, "-d", destDir]);
}

function buildOne(bin: string, game: DiscoveredGame): string | null {
  const slug = game.meta.id;
  const tmp = join(TMP_DIR, slug);
  rmSync(tmp, { recursive: true, force: true });
  mkdirSync(tmp, { recursive: true });
  cpSync(game.sourceAbs, tmp, {
    recursive: true,
    filter: (src: string) => {
      const base = src.split("/").pop() ?? "";
      return !["node_modules", ".git"].includes(base);
    },
  });

  const cmd = [...game.meta.build, "export html out.zip", "exit"].join(" & ");
  console.log(`  → tic80 --fs ${tmp} --cmd "${cmd}"`);
  const r = runTic80(bin, tmp, cmd);
  const zipPath = join(tmp, "out.zip");
  if (!existsSync(zipPath)) {
    console.error(`  ✗ ${slug}: export n'a pas produit out.zip`);
    if (r.output) console.error(r.output.split("\n").map((l) => "      " + l).join("\n"));
    return null;
  }

  const outDir = join(GAMES_OUT, slug);
  rmSync(outDir, { recursive: true, force: true });
  unzip(zipPath, outDir);
  const indexPath = join(outDir, "index.html");
  if (!existsSync(indexPath)) {
    console.error(`  ✗ ${slug}: pas de index.html dans l'export`);
    return null;
  }

  const localJs = join(outDir, "tic80.js");
  const localWasm = join(outDir, "tic80.wasm");
  const sharedJs = join(SHARED_OUT, "tic80.js");
  const sharedWasm = join(SHARED_OUT, "tic80.wasm");
  if (existsSync(localJs) && existsSync(localWasm)) {
    if (!existsSync(sharedJs) || !existsSync(sharedWasm)) {
      mkdirSync(SHARED_OUT, { recursive: true });
      renameSync(localJs, sharedJs);
      renameSync(localWasm, sharedWasm);
      const patched = readFileSync(sharedJs, "utf8").replace(/(['"])tic80\.wasm\1/g, "$1../_shared/tic80.wasm$1");
      writeFileSync(sharedJs, patched);
    } else {
      rmSync(localJs);
      rmSync(localWasm);
    }
    const html = readFileSync(indexPath, "utf8").replace(/(['"])tic80\.js\1/g, "$1../_shared/tic80.js$1");
    writeFileSync(indexPath, html);
  }

  mkdirSync(COVERS_OUT, { recursive: true });
  cpSync(join(game.sourceAbs, game.meta.coverPath), join(COVERS_OUT, `${slug}.png`));
  console.log(`  ✓ ${slug}`);
  return slug;
}

function writeGenerated(games: DiscoveredGame[]) {
  mkdirSync(dirname(GENERATED), { recursive: true });
  const body = games.map((g) => JSON.stringify(g.meta, null, 2)).join(",\n");
  const content = `// AUTO-GENERATED par scripts/build-tic-exports.ts — ne pas éditer à la main.
import type { GameMeta } from "../types/game";

export const GAMES: GameMeta[] = [
${body}
];
`;
  writeFileSync(GENERATED, content);
  console.log(`✓ ${GENERATED} (${games.length} jeu${games.length > 1 ? "x" : ""})`);
}

function main() {
  const { games, warnings } = discoverGames(REPO_ROOT);
  for (const w of warnings) console.warn(`⚠ ${w}`);

  if (games.length === 0) {
    console.error("Aucun jeu valide découvert (cherche `*/game.json` à la racine du repo).");
    process.exit(1);
  }

  console.log(`Jeux découverts : ${games.length}`);
  for (const g of games) console.log(`  - ${g.meta.id} (${g.meta.title})`);

  const bin = findTic80();
  console.log(`TIC-80: ${bin}`);

  mkdirSync(TMP_DIR, { recursive: true });
  rmSync(SHARED_OUT, { recursive: true, force: true });
  mkdirSync(GAMES_OUT, { recursive: true });

  const built: DiscoveredGame[] = [];
  for (const g of games) {
    const slug = buildOne(bin, g);
    if (slug) built.push(g);
  }

  if (built.length === 0) {
    console.error("Aucun export TIC-80 n'a réussi.");
    process.exit(1);
  }

  writeGenerated(built);
  console.log(`\nTerminé : ${built.length}/${games.length} jeux exportés.`);
}

main();
