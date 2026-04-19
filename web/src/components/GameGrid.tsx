import type { GameMeta } from "../types/game";
import { GameCard } from "./GameCard";

export function GameGrid({ games }: { games: GameMeta[] }) {
  if (games.length === 0) {
    return <p>Aucun jeu pour l'instant.</p>;
  }
  return (
    <div className="gallery-grid">
      {games.map((g) => (
        <GameCard key={g.id} game={g} />
      ))}
    </div>
  );
}
