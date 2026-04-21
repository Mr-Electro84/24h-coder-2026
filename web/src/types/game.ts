export type GameLanguage = "Fennel" | "Lua" | "JS" | "Moon" | "Wren" | "Squirrel";

export type GameAward = "jury" | "public";

export type GameControl = { key: string; action: string };

export type GameMeta = {
  id: string;
  title: string;
  team: string;
  authors: string[];
  description: string;
  longDescription?: string;
  genre: string;
  language: GameLanguage;
  controls: GameControl[];
  sourceDir: string;
  coverPath: string;
  build: string[];
  award?: GameAward;
  repoUrl?: string;
};

const LANGS: GameLanguage[] = ["Fennel", "Lua", "JS", "Moon", "Wren", "Squirrel"];
const SLUG_RE = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const FORBIDDEN_BUILD = /^\s*(export\s+html|exit|run)\b/i;

export type ValidationResult =
  | { ok: true; meta: GameMeta }
  | { ok: false; errors: string[] };

export function validateGameMeta(raw: unknown, source: string): ValidationResult {
  const errors: string[] = [];
  const push = (msg: string) => errors.push(`[${source}] ${msg}`);

  if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
    return { ok: false, errors: [`[${source}] le contenu n'est pas un objet JSON`] };
  }
  const r = raw as Record<string, unknown>;

  const str = (k: string) => (typeof r[k] === "string" ? (r[k] as string) : null);
  const arr = (k: string) => (Array.isArray(r[k]) ? (r[k] as unknown[]) : null);

  const id = str("id");
  if (!id) push("`id` manquant ou non-string");
  else if (!SLUG_RE.test(id)) push(`\`id\` "${id}" doit être un slug kebab-case [a-z0-9-]`);

  for (const k of ["title", "team", "description", "genre", "sourceDir", "coverPath"] as const) {
    if (!str(k)) push(`\`${k}\` manquant ou non-string`);
  }

  const lang = str("language");
  if (!lang) push("`language` manquant");
  else if (!LANGS.includes(lang as GameLanguage)) push(`\`language\` "${lang}" non supporté (attendu: ${LANGS.join(", ")})`);

  const authors = arr("authors");
  if (!authors || !authors.every((a) => typeof a === "string"))
    push("`authors` doit être un tableau de strings");

  const controls = arr("controls");
  if (!controls || !controls.every((c) => c && typeof c === "object" && typeof (c as { key?: unknown }).key === "string" && typeof (c as { action?: unknown }).action === "string"))
    push("`controls` doit être un tableau de { key, action }");

  const build = arr("build");
  if (!build || build.length === 0 || !build.every((c) => typeof c === "string"))
    push("`build` doit être un tableau non vide de strings");
  else {
    for (const cmd of build as string[]) {
      if (FORBIDDEN_BUILD.test(cmd))
        push(`\`build\` ne doit pas contenir \`run\`/\`exit\`/\`export html\` (trouvé: "${cmd}")`);
    }
  }

  const AWARDS: GameAward[] = ["jury", "public"];
  const award = str("award");
  if (r.award !== undefined && (!award || !AWARDS.includes(award as GameAward)))
    push(`\`award\` (optionnel) doit valoir "jury" ou "public"`);

  const repoUrl = str("repoUrl");
  if (r.repoUrl !== undefined && (!repoUrl || !/^https?:\/\//.test(repoUrl)))
    push(`\`repoUrl\` (optionnel) doit être une URL http(s)`);

  if (str("longDescription") === null && r.longDescription !== undefined && typeof r.longDescription !== "string")
    push("`longDescription` (optionnel) doit être une string");

  if (errors.length) return { ok: false, errors };

  const meta: GameMeta = {
    id: id!,
    title: str("title")!,
    team: str("team")!,
    authors: (authors as string[]) ?? [],
    description: str("description")!,
    longDescription: str("longDescription") ?? undefined,
    genre: str("genre")!,
    language: lang as GameLanguage,
    controls: (controls as GameControl[]) ?? [],
    sourceDir: str("sourceDir")!,
    coverPath: str("coverPath")!,
    build: build as string[],
    award: (award as GameAward | null) ?? undefined,
    repoUrl: repoUrl ?? undefined,
  };
  return { ok: true, meta };
}
