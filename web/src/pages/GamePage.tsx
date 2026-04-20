import { Link, useParams } from "react-router-dom";
import ReactMarkdown from "react-markdown";
import { GAMES } from "../data/games.generated";
import { PlayerFrame } from "../components/PlayerFrame";

export function GamePage() {
  const { id } = useParams<{ id: string }>();
  const game = GAMES.find((g) => g.id === id);

  if (!game) {
    return (
      <div>
        <Link to="/" className="back-link">← Retour à la galerie</Link>
        <p>Jeu introuvable : <code>{id}</code>.</p>
      </div>
    );
  }

  return (
    <div>
      <Link to="/" className="back-link">← Retour à la galerie</Link>
      <div className="game-page">
        <div>
          <div className="mobile-warning">
            🎮 Clavier requis — ce jeu n'a pas de contrôles tactiles. Jouez sur desktop.
          </div>
          <PlayerFrame slug={game.id} title={game.title} />
        </div>
        <aside>
          <h1>{game.title}</h1>
          <p className="team">par {game.team} · {game.genre} · {game.language}</p>
          <p>{game.description}</p>
          <h3 style={{ fontFamily: "var(--pixel-font)", fontSize: "0.75rem" }}>Contrôles</h3>
          <table className="controls-table">
            <thead>
              <tr><th>Touche</th><th>Action</th></tr>
            </thead>
            <tbody>
              {game.controls.map((c, i) => (
                <tr key={i}><td><code>{c.key}</code></td><td>{c.action}</td></tr>
              ))}
            </tbody>
          </table>
          {game.longDescription && (
            <div className="long-desc">
              <ReactMarkdown>{game.longDescription}</ReactMarkdown>
            </div>
          )}
          <p style={{ fontSize: "0.85rem", marginTop: "1rem" }}>
            <a
              href="https://github.com/BDE-CERI/24h-coder-2026"
              target="_blank"
              rel="noreferrer"
            >
              Voir les sources sur GitHub →
            </a>
          </p>
        </aside>
      </div>
    </div>
  );
}
