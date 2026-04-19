import { Link } from "react-router-dom";
import type { GameMeta } from "../types/game";

export function GameCard({ game }: { game: GameMeta }) {
  return (
    <Link to={`/games/${game.id}`} className="game-card">
      <img
        className="pixel"
        src={`${import.meta.env.BASE_URL}covers/${game.id}.png`}
        alt={game.title}
        loading="lazy"
      />
      <div className="game-card-body">
        <h2>{game.title}</h2>
        <div className="game-card-meta">
          <span>{game.genre}</span>
          <span>{game.team}</span>
        </div>
      </div>
    </Link>
  );
}
