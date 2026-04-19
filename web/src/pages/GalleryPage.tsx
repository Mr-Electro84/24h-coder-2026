import { GAMES } from "../data/games.generated";
import { GameGrid } from "../components/GameGrid";

export function GalleryPage() {
  return (
    <div>
      <p style={{ color: "var(--fg-dim)", marginTop: 0 }}>
        {GAMES.length} jeu{GAMES.length > 1 ? "x" : ""} cette année. Cliquez pour jouer dans le navigateur.
      </p>
      <GameGrid games={GAMES} />
    </div>
  );
}
